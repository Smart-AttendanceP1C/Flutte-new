import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/session_store.dart';
import '../data/auth_repository.dart';

/// Real auth state: login → real backend → real JWT + real role.
/// No hardcoded roles, no fake JWT. Session restored from [SessionStore].
/// Backend roles: student, lecturer, ta, admin, auditor.
///
/// Startup: [restore] MUST be awaited (done in AppDependencies.create
/// before runApp) with a validator that hits the role-appropriate `me`
/// endpoint. A stored token alone never counts as authenticated-for-routing:
/// 401 during validation clears the stale session (old backend DB, expired
/// JWT) so the router lands on Login instead of an authed shell flashing
/// "Invalid or expired token".
class AuthState extends ChangeNotifier {
  final AuthRepository? _repo;
  final SessionStore? _sessions;

  bool _loading = false;
  bool _restoring = true;
  String? _error;
  Map<String, dynamic>? _user;

  /// Production constructor. [restore] must still be awaited before
  /// first routing (AppDependencies.create does this).
  AuthState({required AuthRepository repo, required SessionStore sessions})
      : _repo = repo,
        _sessions = sessions {
    _user = sessions.user;
    // Not validated yet — restore() flips this to false.
    _restoring = true;
    // Keep in sync when SessionStore is cleared centrally (e.g. 401).
    sessions.addListener(_onStoreChanged);
  }

  /// Test constructor (no backend).
  AuthState.test()
      : _repo = null,
        _sessions = null {
    _restoring = false;
  }

  void _onStoreChanged() {
    final stored = _sessions?.user;
    // Only react to external clears (token/user removed).
    if (stored == null && _user != null) {
      _user = null;
      _error = null;
      notifyListeners();
    } else if (stored != null &&
        _user == null &&
        _sessions?.token != null) {
      _user = stored;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessions?.removeListener(_onStoreChanged);
    super.dispose();
  }

  bool get isLoading => _loading;
  bool get isRestoring => _restoring;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated =>
      _user != null && (_sessions?.token ?? _testToken) != null;

  String? _testToken;

  /// Real backend role, verbatim (`student`, `lecturer`, `ta`, `admin`, ...).
  String? get role => _user?['role']?.toString();
  bool get isStudent => role == 'student';
  bool get isInstructor => role == 'lecturer' || role == 'ta';
  bool get isStaff =>
      role == 'lecturer' || role == 'ta' || role == 'admin';

  String get displayName =>
      (_user?['name'] ?? '').toString().isEmpty ? '—' : _user!['name'].toString();
  String get userCode {
    final u = _user;
    if (u == null) return '';
    return (u['student_code'] ?? u['staff_code'] ?? '').toString();
  }

  String get email => (_user?['email'] ?? '').toString();

  /// Validate the persisted session against the REAL backend.
  ///
  /// - No stored token/user → unauthenticated, no network call.
  /// - 401 from [validator] (expired JWT, wrong-backend JWT) → clear the
  ///   stale token + user so the router lands on Login.
  /// - 403 / network failure → keep the optimistic session; the UI shows
  ///   the honest backend error with retry instead of a forced logout.
  Future<void> restore({Future<void> Function()? validator}) async {
    final token = _sessions?.token;
    final storedUser = _sessions?.user;
    if ((token == null || token.isEmpty || storedUser == null) &&
        _testToken == null) {
      _user = null;
      _restoring = false;
      notifyListeners();
      return;
    }
    _user ??= storedUser;
    _restoring = true;
    notifyListeners();
    if (validator == null) {
      _restoring = false;
      notifyListeners();
      return;
    }
    try {
      await validator();
      _restoring = false;
      notifyListeners();
    } on ApiException catch (e) {
      if (e.status == 401) {
        await _repo?.logout();
        _user = null;
        _error = null;
        _testToken = null;
      }
      _restoring = false;
      notifyListeners();
    } catch (_) {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    if (!email.trim().contains('@')) {
      _error = 'invalid_email';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _error = 'short_password';
      notifyListeners();
      return false;
    }
    if (_loading) return false;
    if (_repo == null) {
      _error = 'auth_na';
      notifyListeners();
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      final repo = _repo;
      if (repo == null) {
        _error = 'auth_na';
        return false;
      }
      final result = await repo.login(email: email, password: password);
      _user = result['user'] as Map<String, dynamic>;
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'no_connection';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo?.logout();
    // _onStoreChanged also fires via SessionStore.notifyListeners, but
    // clear locally too for the test constructor (no store).
    _user = null;
    _error = null;
    _testToken = null;
    notifyListeners();
  }

  /// Called centrally when the backend answers 401 (expired/invalid JWT).
  /// Clears the persisted session so stale protected data is never shown.
  Future<void> handleUnauthorized() async {
    await _repo?.logout();
    _user = null;
    _error = null;
    _testToken = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
