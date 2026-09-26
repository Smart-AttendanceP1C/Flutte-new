import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/session_store.dart';

/// UI → [AuthRepository] → [ApiClient] → real backend.
/// No demo/fake login. Role comes from the real login response.
class AuthRepository {
  final ApiClient api;
  final SessionStore sessions;
  AuthRepository({required this.api, required this.sessions});

  /// Returns `{token, user}` on success; throws [ApiException] otherwise.
  /// Login is an UNAUTHENTICATED request: no stale Bearer is sent, and a
  /// 401 for invalid credentials never triggers the global logout hook.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await api.post(
      ApiConfig.loginPath,
      body: {'email': email.trim(), 'password': password},
      auth: false,
    ) as Map<String, dynamic>;
    final token = (data['access_token'] ?? '').toString();
    final user = Map<String, dynamic>.from(data['user'] as Map);
    if (token.isEmpty) {
      throw const ApiException(
        code: 'LOGIN_FAILED',
        message: 'Login succeeded but no token was returned.',
        status: 200,
      );
    }
    await sessions.save(token: token, user: user);
    return {'token': token, 'user': user};
  }

  Future<void> logout() => sessions.clear();
}
