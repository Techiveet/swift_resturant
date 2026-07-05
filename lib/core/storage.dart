import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin persistence layer over SharedPreferences for the auth token, the
/// logged-in restaurant, and the live-socket (Reverb) config.
class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kToken = 'access_token';
  static const _kTokenType = 'token_type';
  static const _kRestaurant = 'restaurant';
  static const _kPushConfig = 'push_config';
  static const _kCurrency = 'currency';

  String? get token => _prefs.getString(_kToken);
  String get tokenType => _prefs.getString(_kTokenType) ?? 'Bearer';
  bool get isLoggedIn => (token ?? '').isNotEmpty;

  Future<void> saveToken(String token, String tokenType) async {
    await _prefs.setString(_kToken, token);
    await _prefs.setString(_kTokenType, tokenType);
  }

  Map<String, dynamic>? get restaurant {
    final raw = _prefs.getString(_kRestaurant);
    if (raw == null || raw.isEmpty) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRestaurant(Map<String, dynamic> data) =>
      _prefs.setString(_kRestaurant, json.encode(data));

  Map<String, dynamic>? get pushConfig {
    final raw = _prefs.getString(_kPushConfig);
    if (raw == null || raw.isEmpty) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> savePushConfig(Map<String, dynamic>? data) async {
    if (data == null) return;
    await _prefs.setString(_kPushConfig, json.encode(data));
  }

  String get currency => _prefs.getString(_kCurrency) ?? '';
  Future<void> saveCurrency(String? symbol) async {
    if (symbol == null) return;
    await _prefs.setString(_kCurrency, symbol);
  }

  Future<void> clear() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kTokenType);
    await _prefs.remove(_kRestaurant);
    // Keep push_config/currency — harmless and avoids a re-fetch on next login.
  }
}
