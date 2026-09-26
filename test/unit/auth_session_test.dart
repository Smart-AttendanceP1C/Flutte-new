import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verishift_app/core/app.dart';
import 'package:verishift_app/core/network/api_client.dart';
import 'package:verishift_app/core/storage/session_store.dart';
import 'package:verishift_app/features/auth/data/auth_repository.dart';
import 'package:verishift_app/features/auth/state/auth_state.dart';
import 'package:verishift_app/features/instructor/data/instructor_api.dart';
import 'package:verishift_app/features/student/data/student_api.dart';

http.Response _ok(Object data) => http.Response(
      jsonEncode({'success': true, 'data': data}),
      200,
      headers: {'content-type': 'application/json'},
    );

http.Response _err(int status, String code, String message) => http.Response(
      jsonEncode({
        'success': false,
        'error': {'code': code, 'message': message}
      }),
      status,
      headers: {'content-type': 'application/json'},
    );

Map<String, dynamic> _studentUser() =>
    {'id': 1, 'name': 'Test Student', 'email': 's@bua.edu.eg', 'role': 'student'};

Map<String, dynamic> _staffUser() => {
      'id': 2,
      'name': 'Test Lecturer',
      'email': 'l@bua.edu.eg',
      'role': 'lecturer'
    };

Future<SessionStore> _storeWith(
    {required String token, required Map<String, dynamic> user}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final s = SessionStore(prefs);
  await s.save(token: token, user: user);
  return s;
}

void main() {
  test('restore with no stored session makes zero network calls', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sessions = SessionStore(prefs);
    var calls = 0;
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient((_) async {
        calls++;
        return _ok({});
      }),
    );
    final auth = AuthState(
      repo: AuthRepository(api: api, sessions: sessions),
      sessions: sessions,
    );
    await auth.restore(
      validator: () => AppDependencies.validateStoredSession(
          StudentApi(api), InstructorApi(api), sessions),
    );
    expect(auth.isAuthenticated, isFalse);
    expect(auth.isRestoring, isFalse);
    expect(calls, 0);
  });

  test('restore with valid student JWT keeps the session', () async {
    final sessions =
        await _storeWith(token: 'good-jwt', user: _studentUser());
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient((req) async {
        expect(req.headers['Authorization'], 'Bearer good-jwt');
        if (req.url.path == '/api/v1/students/me') {
          return _ok({
            'id': 1,
            'name': 'Test Student',
            'email': 's@bua.edu.eg',
            'student_code': 'STU-1',
            'status': 'active',
          });
        }
        return _err(404, 'NOT_FOUND', 'nope');
      }),
    );
    final auth = AuthState(
      repo: AuthRepository(api: api, sessions: sessions),
      sessions: sessions,
    );
    await auth.restore(
      validator: () => AppDependencies.validateStoredSession(
          StudentApi(api), InstructorApi(api), sessions),
    );
    expect(auth.isAuthenticated, isTrue);
    expect(auth.role, 'student');
    expect(sessions.token, 'good-jwt');
  });

  test('restore with 401 clears stale token and user', () async {
    final sessions =
        await _storeWith(token: 'stale-jwt', user: _studentUser());
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient((_) async =>
          _err(401, 'INVALID_TOKEN', 'Invalid or expired token')),
    );
    final auth = AuthState(
      repo: AuthRepository(api: api, sessions: sessions),
      sessions: sessions,
    );
    // Central 401 hook mirrors production wiring.
    api.onUnauthorized = () => auth.handleUnauthorized();
    await auth.restore(
      validator: () => AppDependencies.validateStoredSession(
          StudentApi(api), InstructorApi(api), sessions),
    );
    expect(auth.isAuthenticated, isFalse);
    expect(auth.isRestoring, isFalse);
    expect(sessions.token, isNull);
    expect(sessions.user, isNull);
  });

  test('restore with 403 keeps session (valid token, no scope)', () async {
    final sessions =
        await _storeWith(token: 'valid-no-scope', user: _staffUser());
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient(
          (_) async => _err(403, 'FORBIDDEN', 'Staff access required')),
    );
    final auth = AuthState(
      repo: AuthRepository(api: api, sessions: sessions),
      sessions: sessions,
    );
    await auth.restore(
      validator: () => AppDependencies.validateStoredSession(
          StudentApi(api), InstructorApi(api), sessions),
    );
    // Not wiped: the token itself is fine, routing shows the honest 403.
    expect(auth.isAuthenticated, isTrue);
    expect(sessions.token, 'valid-no-scope');
  });

  test('mid-session 401 evicts the session via onUnauthorized', () async {
    final sessions =
        await _storeWith(token: 'expiring-jwt', user: _studentUser());
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient(
          (_) async => _err(401, 'INVALID_TOKEN', 'Invalid or expired token')),
    );
    final auth = AuthState(
      repo: AuthRepository(api: api, sessions: sessions),
      sessions: sessions,
    );
    api.onUnauthorized = () => auth.handleUnauthorized();
    expect(auth.isAuthenticated, isTrue);
    await expectLater(
      StudentApi(api).me(),
      throwsA(isA<Exception>()),
    );
    // Fire-and-forget hook runs async; allow it to complete.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(auth.isAuthenticated, isFalse);
    expect(sessions.token, isNull);
  });

  test('login stores the NEW token used by protected endpoints', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sessions = SessionStore(prefs);
    String? loginAuth;
    String? seenAuth;
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient((req) async {
        if (req.url.path == '/api/v1/auth/login') {
          loginAuth = req.headers['Authorization'];
          return _ok({
            'access_token': 'fresh-jwt-123',
            'user': _studentUser(),
          });
        }
        seenAuth = req.headers['Authorization'];
        return _ok({
          'id': 1,
          'name': 'Test Student',
          'email': 's@bua.edu.eg',
          'student_code': 'STU-1',
          'status': 'active',
        });
      }),
    );
    final repo = AuthRepository(api: api, sessions: sessions);
    final result =
        await repo.login(email: 's@bua.edu.eg', password: 'Password123!');
    expect(result['token'], 'fresh-jwt-123');
    expect(sessions.token, 'fresh-jwt-123');
    // Role comes from the real login response, never hardcoded.
    expect((result['user'] as Map)['role'], 'student');
    // Login itself carried no stale Bearer; later calls use the NEW token.
    expect(loginAuth, isNull);
    await StudentApi(api).me();
    expect(seenAuth, 'Bearer fresh-jwt-123');
  });

  test('failed login sends no Bearer and keeps the prior session intact',
      () async {
    final sessions =
        await _storeWith(token: 'prior-jwt', user: _studentUser());
    String? loginAuth;
    var logoutFired = false;
    final api = ApiClient(
      tokenProvider: () async => sessions.token,
      httpClient: MockClient((req) async {
        loginAuth = req.headers['Authorization'];
        return _err(401, 'INVALID_CREDENTIALS', 'Invalid email or password');
      }),
      onUnauthorized: () async => logoutFired = true,
    );
    final repo = AuthRepository(api: api, sessions: sessions);
    await expectLater(
      () => repo.login(email: 's@bua.edu.eg', password: 'wrong-password1'),
      throwsA(isA<Exception>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(loginAuth, isNull);
    // The global logout hook must NOT run for a login 401.
    expect(logoutFired, isFalse);
    expect(sessions.token, 'prior-jwt');
    expect(sessions.user, isNotNull);
  });
}
