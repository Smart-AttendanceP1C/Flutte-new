import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:verishift_app/core/network/api_client.dart';
import 'package:verishift_app/core/network/api_exception.dart';

ApiClient _client(MockClient c) =>
    ApiClient(tokenProvider: () async => 't', httpClient: c);

void main() {
  test('GET returns data field on success', () async {
    final c = _client(MockClient((_) async => http.Response(
        jsonEncode({
          'success': true,
          'data': [
            {'id': 1}
          ]
        }),
        200)));
    final data = await c.get('/api/v1/courses');
    expect(data, isA<List>());
  });

  test('GET throws ApiException with backend code/message', () async {
    final c = _client(MockClient((_) async => http.Response(
        jsonEncode({
          'success': false,
          'error': {
            'code': 'INVALID_CREDENTIALS',
            'message': 'Invalid email or password',
            'request_id': 'r1'
          }
        }),
        401)));
    expect(
      () => c.get('/api/v1/courses'),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')
          .having((e) => e.status, 'status', 401)
          .having((e) => e.requestId, 'requestId', 'r1')),
    );
  });

  test('POST login validation error surfaces', () async {
    final c = _client(MockClient((_) async => http.Response(
        jsonEncode({
          'success': false,
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Email and password are required'
          }
        }),
        400)));
    expect(
      () => c.post('/api/v1/auth/login', body: {}),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'VALIDATION_ERROR')),
    );
  });

  test('Bearer header is attached on authenticated requests', () async {
    String? auth;
    final c = _client(MockClient((req) async {
      auth = req.headers['Authorization'];
      return http.Response(
          jsonEncode({'success': true, 'data': []}), 200);
    }));
    await c.get('/api/v1/courses');
    expect(auth, 'Bearer t');
  });

  test('unauthenticated request sends no Bearer even with a stored token',
      () async {
    String? auth;
    final c = _client(MockClient((req) async {
      auth = req.headers['Authorization'];
      return http.Response(
          jsonEncode({'success': true, 'data': []}), 200);
    }));
    await c.post('/api/v1/auth/login',
        body: {'email': 'a@b.c', 'password': 'secret123'}, auth: false);
    expect(auth, isNull);
  });

  test('401 on unauthenticated request does NOT fire onUnauthorized',
      () async {
    var fired = false;
    final c = ApiClient(
      tokenProvider: () async => 'stale-jwt',
      httpClient: MockClient((_) async => http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'code': 'INVALID_CREDENTIALS',
              'message': 'Invalid email or password'
            }
          }),
          401)),
      onUnauthorized: () async => fired = true,
    );
    await expectLater(
      () => c.post('/api/v1/auth/login',
          body: {'email': 'a@b.c', 'password': 'wrongpass'}, auth: false),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')
          .having((e) => e.status, 'status', 401)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(fired, isFalse);
  });

  test('401 on authenticated request still fires onUnauthorized', () async {
    var fired = false;
    final c = ApiClient(
      tokenProvider: () async => 'expired-jwt',
      httpClient: MockClient((_) async => http.Response(
          jsonEncode({
            'success': false,
            'error': {'code': 'INVALID_TOKEN', 'message': 'Expired'}
          }),
          401)),
      onUnauthorized: () async => fired = true,
    );
    await expectLater(
      () => c.get('/api/v1/students/me'),
      throwsA(isA<ApiException>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(fired, isTrue);
  });
}
