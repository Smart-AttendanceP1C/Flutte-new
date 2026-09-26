import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted session: real JWT + real user. Stateless logout = clear.
/// Keys are app-private; no passwords are ever stored.
class SessionStore extends ChangeNotifier {
  static const _kToken = 'sa.token';
  static const _kUser = 'sa.user';

  final SharedPreferences _prefs;
  SessionStore(this._prefs);

  static Future<SessionStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionStore(prefs);
  }

  /// Test/in-memory constructor.
  SessionStore.memory(this._prefs);

  String? get token => _prefs.getString(_kToken);
  Map<String, dynamic>? get user {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> save({required String token, required Map<String, dynamic> user}) async {
    await _prefs.setString(_kToken, token);
    await _prefs.setString(_kUser, jsonEncode(user));
    notifyListeners();
  }

  Future<void> clear() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kUser);
    notifyListeners();
  }
}
