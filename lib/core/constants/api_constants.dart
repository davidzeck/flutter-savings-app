/// API configuration constants
///
/// Contains base URLs, endpoints, and API-related configuration.
/// Use environment variables for sensitive data in production.
class ApiConstants {
  ApiConstants._(); // Private constructor

  // ============================================================================
  // BASE URLS
  // ============================================================================

  /// Base URL for API endpoints
  /// In production, this should be loaded from environment variables
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  /// API version
  static const String apiVersion = 'v1';

  /// Full API URL with version
  static String get apiUrl => '$baseUrl/$apiVersion';

  // ============================================================================
  // TIMEOUTS (in seconds)
  // ============================================================================

  /// Connection timeout
  static const int connectTimeout = 30;

  /// Receive timeout
  static const int receiveTimeout = 30;

  /// Send timeout
  static const int sendTimeout = 30;

  // ============================================================================
  // ENDPOINTS - Authentication
  // ============================================================================

  /// Login endpoint
  static const String login = '/auth/login';

  /// Logout endpoint
  static const String logout = '/auth/logout';

  /// Refresh token endpoint
  static const String refreshToken = '/auth/refresh';

  /// Register endpoint
  static const String register = '/auth/register';

  /// Forgot password endpoint
  static const String forgotPassword = '/auth/forgot-password';

  /// Reset password endpoint
  static const String resetPassword = '/auth/reset-password';

  // ============================================================================
  // ENDPOINTS - User
  // ============================================================================

  /// Get current user endpoint
  static const String currentUser = '/users/me';

  /// Update user profile endpoint
  static const String updateProfile = '/users/me';

  /// Get user by ID endpoint (use with string interpolation)
  static String getUserById(String id) => '/users/$id';

  // ============================================================================
  // ENDPOINTS - Dashboard
  // ============================================================================

  /// Get dashboard items endpoint
  static const String dashboardItems = '/dashboard/items';

  /// Refresh dashboard endpoint
  static const String dashboardRefresh = '/dashboard/refresh';

  /// Get dashboard item by ID
  static String getDashboardItem(String id) => '/dashboard/items/$id';

  // ============================================================================
  // ENDPOINTS - Settings
  // ============================================================================

  /// Get user settings
  static const String settings = '/settings';

  /// Update user settings
  static const String updateSettings = '/settings';

  // ============================================================================
  // HEADERS
  // ============================================================================

  /// Content type header key
  static const String contentType = 'Content-Type';

  /// Authorization header key
  static const String authorization = 'Authorization';

  /// Accept header key
  static const String accept = 'Accept';

  /// Default content type value
  static const String applicationJson = 'application/json';

  /// Bearer token prefix
  static const String bearer = 'Bearer';

  // ============================================================================
  // PAGINATION
  // ============================================================================

  /// Default page size for paginated requests
  static const int defaultPageSize = 20;

  /// Maximum page size
  static const int maxPageSize = 100;

  /// Default page number
  static const int defaultPage = 1;

  // ============================================================================
  // CACHE
  // ============================================================================

  /// Cache duration for dashboard data (in hours)
  static const int cacheDurationHours = 1;

  /// Maximum cache size (in MB)
  static const int maxCacheSizeMB = 50;

  // ============================================================================
  // RETRY CONFIGURATION
  // ============================================================================

  /// Maximum number of retry attempts
  static const int maxRetries = 3;

  /// Delay between retries (in milliseconds)
  static const int retryDelay = 1000;

  // ============================================================================
  // ERROR CODES
  // ============================================================================

  /// Unauthorized error code
  static const int unauthorized = 401;

  /// Forbidden error code
  static const int forbidden = 403;

  /// Not found error code
  static const int notFound = 404;

  /// Internal server error code
  static const int internalServerError = 500;

  /// Service unavailable error code
  static const int serviceUnavailable = 503;
}
