import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tobbo/data/services/api_service.dart';
import 'package:Tobbo/domain/repositories/session_repository.dart';

class SessionRepositoryImpl extends ChangeNotifier implements SessionRepository {
  SessionRepositoryImpl({
    required ApiService api,
    required AuthTokenStore tokens,
    required SharedPreferences prefs,
  })  : _api = api,
        _tokens = tokens,
        _prefs = prefs {
    _hydrate();
  }

  static const _tokenKey = 'tobbo_access_token';
  static const _expiresKey = 'tobbo_token_expires_at';
  static const _userIdKey = 'tobbo_anonymous_user_id';
  static const _tokenHashKey = 'tobbo_token_hash';

  final ApiService _api;
  final AuthTokenStore _tokens;
  final SharedPreferences _prefs;
  Future<String>? _ensuring;

  @override
  bool get hasStoredIdentity {
    final token = _prefs.getString(_tokenKey);
    final userId = _prefs.getString(_userIdKey);
    final tokenHash = _prefs.getString(_tokenHashKey);
    return _isPresent(token) || _isPresent(userId) || _isPresent(tokenHash);
  }

  void _hydrate() {
    final token = _prefs.getString(_tokenKey);
    final expires = _prefs.getString(_expiresKey);
    if (token == null || token.isEmpty || expires == null) return;
    final expiresAt = DateTime.tryParse(expires)?.toUtc();
    if (expiresAt == null || !expiresAt.isAfter(DateTime.now().toUtc())) return;
    _tokens.token = token;
    _tokens.expiresAt = expiresAt;
  }

  @override
  Future<String> ensureSession() async {
    if (_tokens.isValid) return _tokens.token!;
    final pending = _ensuring;
    if (pending != null) return pending;
    final future = _createSession();
    _ensuring = future;
    try {
      return await future;
    } finally {
      if (identical(_ensuring, future)) _ensuring = null;
    }
  }

  Future<String> _createSession() async {
    if (_tokens.isValid) return _tokens.token!;
    final response = await _api.createAnonymous();
    await _save(
      token: response.accessToken,
      expiresAt: response.expiresAt,
      userId: response.userId,
      tokenHash: response.tokenHash,
    );
    return response.accessToken;
  }

  @override
  Future<String> refreshSession() async {
    _tokens.clear();
    return ensureSession();
  }

  @override
  Future<void> clearSession() async {
    _tokens.clear();
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_expiresKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_tokenHashKey);
    notifyListeners();
  }

  Future<void> _save({
    required String token,
    required DateTime expiresAt,
    String? userId,
    String? tokenHash,
  }) async {
    _tokens.token = token;
    _tokens.expiresAt = expiresAt;
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_expiresKey, expiresAt.toIso8601String());
    if (userId != null && userId.isNotEmpty) {
      await _prefs.setString(_userIdKey, userId);
    }
    if (tokenHash != null && tokenHash.isNotEmpty) {
      await _prefs.setString(_tokenHashKey, tokenHash);
    }
    notifyListeners();
  }

  bool _isPresent(String? value) => value != null && value.isNotEmpty;
}
