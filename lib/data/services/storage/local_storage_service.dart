import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Local storage service for persistent data
///
/// Provides two types of storage:
/// - Secure Storage: For sensitive data (tokens, credentials)
/// - Shared Preferences: For non-sensitive cached data
class LocalStorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  LocalStorageService(this._prefs, this._secureStorage);

  // ============================================================================
  // SECURE STORAGE (For sensitive data)
  // ============================================================================

  /// Save auth token securely
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _StorageKeys.authToken, value: token);
    } catch (e) {
      throw StorageWriteException('Failed to save token: $e');
    }
  }

  /// Get auth token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _StorageKeys.authToken);
    } catch (e) {
      throw StorageReadException('Failed to read token: $e');
    }
  }

  /// Clear auth token
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _StorageKeys.authToken);
    } catch (e) {
      throw StorageException('Failed to clear token: $e');
    }
  }

  /// Check if user has a valid token
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================================
  // SHARED PREFERENCES (For non-sensitive data)
  // ============================================================================

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _prefs.setString(_StorageKeys.userData, jsonString);
    } catch (e) {
      throw StorageWriteException('Failed to save user data: $e');
    }
  }

  /// Get user data
  Map<String, dynamic>? getUserData() {
    try {
      final jsonString = _prefs.getString(_StorageKeys.userData);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageReadException('Failed to read user data: $e');
    }
  }

  /// Clear user data
  Future<void> clearUserData() async {
    try {
      await _prefs.remove(_StorageKeys.userData);
    } catch (e) {
      throw StorageException('Failed to clear user data: $e');
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Save cached items
  Future<void> cacheItems(List<Map<String, dynamic>> items) async {
    try {
      final jsonString = jsonEncode(items);
      await _prefs.setString(_StorageKeys.cachedItems, jsonString);
      await _saveCacheTimestamp();
    } catch (e) {
      throw StorageWriteException('Failed to cache items: $e');
    }
  }

  /// Get cached items
  List<Map<String, dynamic>>? getCachedItems() {
    try {
      final jsonString = _prefs.getString(_StorageKeys.cachedItems);
      if (jsonString == null) return null;

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      throw StorageReadException('Failed to read cached items: $e');
    }
  }

  /// Clear cached items
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_StorageKeys.cachedItems);
      await _prefs.remove(_StorageKeys.cacheTimestamp);
    } catch (e) {
      throw StorageException('Failed to clear cache: $e');
    }
  }

  /// Check if cache is valid
  bool isCacheValid({Duration maxAge = const Duration(hours: 1)}) {
    try {
      final timestamp = _prefs.getInt(_StorageKeys.cacheTimestamp);
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      return now.difference(cacheTime) < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// Save cache timestamp
  Future<void> _saveCacheTimestamp() async {
    await _prefs.setInt(
      _StorageKeys.cacheTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ============================================================================
  // SETTINGS
  // ============================================================================

  /// Save theme mode
  Future<void> saveThemeMode(String mode) async {
    try {
      await _prefs.setString(_StorageKeys.themeMode, mode);
    } catch (e) {
      throw StorageWriteException('Failed to save theme mode: $e');
    }
  }

  /// Get theme mode
  String getThemeMode() {
    return _prefs.getString(_StorageKeys.themeMode) ?? 'system';
  }

  /// Save language code
  Future<void> saveLanguage(String languageCode) async {
    try {
      await _prefs.setString(_StorageKeys.language, languageCode);
    } catch (e) {
      throw StorageWriteException('Failed to save language: $e');
    }
  }

  /// Get language code
  String getLanguage() {
    return _prefs.getString(_StorageKeys.language) ?? 'en';
  }

  /// Save onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_StorageKeys.onboardingCompleted, completed);
  }

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _prefs.getBool(_StorageKeys.onboardingCompleted) ?? false;
  }

  // ============================================================================
  // CLEAR ALL DATA
  // ============================================================================

  /// Clear all storage (logout)
  Future<void> clearAll() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();

      // Clear shared preferences (except settings)
      final theme = getThemeMode();
      final language = getLanguage();
      final onboarding = isOnboardingCompleted();

      await _prefs.clear();

      // Restore settings
      await saveThemeMode(theme);
      await saveLanguage(language);
      await setOnboardingCompleted(onboarding);
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }
}

/// Storage keys constants
class _StorageKeys {
  _StorageKeys._();

  // Secure Storage Keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';

  // Shared Preferences Keys
  static const String userData = 'user_data';
  static const String cachedItems = 'cached_items';
  static const String cacheTimestamp = 'cache_timestamp';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String onboardingCompleted = 'onboarding_completed';
}
