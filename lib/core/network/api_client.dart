import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

/// Clean API layer: UI → state → repository → [ApiClient] → real backend.
/// Sends JSON, attaches `Authorization: Bearer <token>` on authenticated
/// requests, and parses the real success/error envelope. Never fabricates
/// responses.
/// Transport failures (timeout, connection loss) surface as [ApiException]
/// with distinct codes — never fake data, never masked as something else.
class ApiClient {
  static const timeout = Duration(seconds: 20);

  final Future<String?> Function() tokenProvider;
  Future<void> Function()? onUnauthorized;
  final http.Client _http;

  ApiClient(
      {required this.tokenProvider, http.Client? httpClient, this.onUnauthorized})
      : _http = httpClient ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(ApiConfig.baseUrl + path);
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...query});
  }

  /// DEBUG-only HTTP tracing (no secrets): method + URL + status +
  /// redacted outcome. NEVER prints passwords, JWTs, QR/scan tokens, or the
  /// Authorization header. Release builds stay silent.
  static void _logReq(String method, Uri uri) {
    if (!kDebugMode) return;
    debugPrint('[API] $method $uri');
  }

  static String _redactOutcome(dynamic body) {
    try {
      if (body is Map) {
        final err = body['error'];
        if (err is Map) {
          return 'err code=${err['code']} msg=${err['message']} '
              'req=${err['request_id']}';
        }
        if (body.containsKey('data')) {
          final d = body['data'];
          if (d is List) return 'ok list(${d.length})';
          if (d is Map) return 'ok keys=${d.keys.take(6).join(',')}';
          return 'ok data';
        }
        return 'ok';
      }
      if (body is List) return 'ok list(${body.length})';
      if (body == null) return 'ok empty';
      return 'ok';
    } catch (_) {
      return 'ok';
    }
  }

  static void _logRes(String method, Uri uri, int status, dynamic body) {
    if (!kDebugMode) return;
    debugPrint('[API] $method $uri -> $status ${_redactOutcome(body)}');
  }

  /// When [auth] is false the request is sent WITHOUT an Authorization
  /// header (e.g. POST /api/v1/auth/login must never carry a stale token).
  Future<Map<String, String>> _headers(
      {bool json = true, bool auth = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (!auth) return headers;
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response res) {
    final contentType = res.headers['content-type'] ?? '';
    if (contentType.contains('text/csv') ||
        contentType.contains('application/pdf')) {
      return res.bodyBytes;
    }
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw ApiException(
        code: 'BAD_RESPONSE',
        message: 'Unreadable server response (HTTP ${res.statusCode}).',
        status: res.statusCode,
      );
    }
  }

  /// [authenticatedRequest] gates the global 401 hook: only protected
  /// (authenticated) requests may trigger [onUnauthorized]. A 401 from an
  /// unauthenticated call (e.g. invalid credentials on login) is thrown as a
  /// normal [ApiException] and must NOT log the user out.
  Never _throwError(http.Response res, dynamic body,
      {bool authenticatedRequest = true}) {
    if (res.statusCode == 401 && authenticatedRequest) {
      // Fire-and-forget: clear the stale session so the router bounces to
      // Login. The original 401 is still thrown for honest UI errors.
      final cb = onUnauthorized;
      if (cb != null) {
        // ignore: discarded_futures
        cb();
      }
    }
    if (body is Map) {
      final err = body['error'];
      if (err is Map) {
        throw ApiException(
          code: (err['code'] ?? 'SERVER_ERROR').toString(),
          message: (err['message'] ?? 'Something went wrong.').toString(),
          status: res.statusCode,
          requestId: err['request_id']?.toString(),
        );
      }
      final msg = body['message']?.toString();
      if (msg != null) {
        throw ApiException(
          code: 'SERVER_ERROR',
          message: msg,
          status: res.statusCode,
        );
      }
    }
    throw ApiException(
      code: 'SERVER_ERROR',
      message: 'Request failed (HTTP ${res.statusCode}).',
      status: res.statusCode,
    );
  }

  /// Returns the decoded `data` field on success (or the full body when
  /// the endpoint returns a file / non-envelope payload).
  /// Pass [auth]: false for unauthenticated endpoints (login).
  Future<dynamic> get(String path,
      {Map<String, String>? query, bool auth = true}) async {
    final uri = _uri(path, query);
    _logReq('GET', uri);
    late final http.Response res;
    try {
      res = await _http
          .get(
            uri,
            headers: await _headers(json: false, auth: auth),
          )
          .timeout(timeout);
    } on TimeoutException {
      if (kDebugMode) debugPrint('[API] GET $uri -> TIMEOUT');
      throw const ApiException(
        code: 'TIMEOUT',
        message: 'no_connection',
        status: 0,
      );
    } on http.ClientException {
      if (kDebugMode) debugPrint('[API] GET $uri -> CONNECTION_FAILED');
      throw const ApiException(
        code: 'CONNECTION_FAILED',
        message: 'no_connection',
        status: 0,
      );
    }
    final body = _decode(res);
    _logRes('GET', uri, res.statusCode, body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body is List<int>) return body;
      if (body is Map && body.containsKey('data')) return body['data'];
      return body;
    }
    _throwError(res, body, authenticatedRequest: auth);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final uri = _uri(path);
    _logReq('POST', uri);
    late final http.Response res;
    try {
      res = await _http
          .post(
            uri,
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      if (kDebugMode) debugPrint('[API] POST $uri -> TIMEOUT');
      throw const ApiException(
        code: 'TIMEOUT',
        message: 'no_connection',
        status: 0,
      );
    } on http.ClientException {
      if (kDebugMode) debugPrint('[API] POST $uri -> CONNECTION_FAILED');
      throw const ApiException(
        code: 'CONNECTION_FAILED',
        message: 'no_connection',
        status: 0,
      );
    }
    final decoded = _decode(res);
    _logRes('POST', uri, res.statusCode, decoded);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }
    _throwError(res, decoded, authenticatedRequest: auth);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    final uri = _uri(path);
    _logReq('PATCH', uri);
    late final http.Response res;
    try {
      res = await _http
          .patch(
            uri,
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      if (kDebugMode) debugPrint('[API] PATCH $uri -> TIMEOUT');
      throw const ApiException(
        code: 'TIMEOUT',
        message: 'no_connection',
        status: 0,
      );
    } on http.ClientException {
      if (kDebugMode) debugPrint('[API] PATCH $uri -> CONNECTION_FAILED');
      throw const ApiException(
        code: 'CONNECTION_FAILED',
        message: 'no_connection',
        status: 0,
      );
    }
    final decoded = _decode(res);
    _logRes('PATCH', uri, res.statusCode, decoded);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }
    _throwError(res, decoded, authenticatedRequest: auth);
  }
}
