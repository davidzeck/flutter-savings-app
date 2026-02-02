import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/network_info.dart';
import '../models/user.dart';
import '../services/api/api_service.dart';
import '../services/storage/local_storage_service.dart';

/// Repository for user-related operations
///
/// Handles:
/// - User authentication (login/logout)
/// - User profile management
/// - Offline-first data access
/// - Token management
class UserRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;
  final NetworkInfo _networkInfo;

  // In-memory cache
  User? _cachedUser;

  UserRepository(
    this._apiService,
    this._localStorage,
    this._networkInfo,
  );

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  /// Login user with email and password
  ///
  /// Returns [User] on success
  /// Throws [InvalidCredentialsException] if credentials are invalid
  /// Throws [NetworkException] if no connection
  /// Throws [ServerException] on server error
  Future<User> login(String email, String password) async {
    try {
      // Make API call
      final response = await _apiService.login(email, password);

      // Extract data from response
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;

      // Parse user
      final user = User.fromJson(userJson);

      // Save token securely
      await _localStorage.saveToken(token);

      // Cache user data
      await _localStorage.saveUserData(userJson);
      _cachedUser = user;

      return user;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Login failed: $e');
    }
  }

  /// Logout current user
  ///
  /// Clears all user data and tokens
  Future<void> logout() async {
    try {
      // Try to call logout endpoint (best effort)
      await _apiService.logout();
    } catch (e) {
      // Continue with local logout even if API fails
      print('Logout API call failed: $e');
    } finally {
      // Always clear local data
      await _clearLocalUserData();
    }
  }

  /// Check if user is authenticated
  ///
  /// Returns true if valid token exists
  Future<bool> isAuthenticated() async {
    return await _localStorage.hasToken();
  }

  // ============================================================================
  // USER DATA
  // ============================================================================

  /// Get current user
  ///
  /// Returns cached user if available, otherwise fetches from server
  /// Falls back to local storage if offline
  Future<User?> getCurrentUser() async {
    // Return in-memory cache if available
    if (_cachedUser != null) {
      return _cachedUser;
    }

    // Try to get from local storage
    final localUserData = _localStorage.getUserData();
    if (localUserData != null) {
      try {
        _cachedUser = User.fromJson(localUserData);

        // Fetch fresh data in background if online
        if (await _networkInfo.isConnected) {
          _refreshUserInBackground();
        }

        return _cachedUser;
      } catch (e) {
        print('Error parsing cached user: $e');
      }
    }

    // Fetch from server if we have a token
    if (await isAuthenticated()) {
      try {
        if (await _networkInfo.isConnected) {
          return await _fetchCurrentUser();
        }
      } catch (e) {
        print('Error fetching user from server: $e');
      }
    }

    return null;
  }

  /// Fetch current user from server
  Future<User> _fetchCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      final userJson = response.data as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      // Update cache
      await _localStorage.saveUserData(userJson);
      _cachedUser = user;

      return user;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Failed to fetch user: $e');
    }
  }

  /// Update user profile
  ///
  /// Returns updated [User] on success
  Future<User> updateProfile({
    required String name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        throw const NetworkException();
      }

      final response = await _apiService.updateProfile(
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      final userJson = response.data as Map<String, dynamic>;
      final updatedUser = User.fromJson(userJson);

      // Update cache
      await _localStorage.saveUserData(userJson);
      _cachedUser = updatedUser;

      return updatedUser;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Failed to update profile: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Clear all local user data
  Future<void> _clearLocalUserData() async {
    await _localStorage.clearToken();
    await _localStorage.clearUserData();
    _cachedUser = null;
  }

  /// Refresh user data in background (fire and forget)
  void _refreshUserInBackground() {
    _fetchCurrentUser().then((_) {
      print('Background user refresh completed');
    }).catchError((error) {
      print('Background user refresh failed: $error');
    });
  }
}
