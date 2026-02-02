/// String constants for the application
///
/// Centralized location for all app strings, error messages, and labels.
/// This makes it easier to implement internationalization (i18n) later.
class AppStrings {
  AppStrings._(); // Private constructor

  // ============================================================================
  // APP INFORMATION
  // ============================================================================

  static const String appName = 'Enterprise Operations';
  static const String appVersion = '1.0.0';

  // ============================================================================
  // GENERAL
  // ============================================================================

  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String loading = 'Loading...';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';
  static const String yes = 'Yes';
  static const String no = 'No';

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String rememberMe = 'Remember Me';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';

  // ============================================================================
  // VALIDATION MESSAGES
  // ============================================================================

  static const String fieldRequired = 'This field is required';
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String invalidEmail = 'Invalid email format';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidCredentials = 'Invalid email or password';

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================

  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'No internet connection';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnauthorized = 'Unauthorized. Please login again.';
  static const String errorNotFound = 'Resource not found';
  static const String errorForbidden = 'Access forbidden';
  static const String errorValidation = 'Validation error';
  static const String errorUnknown = 'Unknown error occurred';

  // ============================================================================
  // SUCCESS MESSAGES
  // ============================================================================

  static const String loginSuccess = 'Login successful';
  static const String logoutSuccess = 'Logout successful';
  static const String saveSuccess = 'Saved successfully';
  static const String deleteSuccess = 'Deleted successfully';
  static const String updateSuccess = 'Updated successfully';

  // ============================================================================
  // DASHBOARD
  // ============================================================================

  static const String dashboard = 'Dashboard';
  static const String noDashboardItems = 'No items to display';
  static const String refreshDashboard = 'Pull to refresh';
  static const String loadingDashboard = 'Loading dashboard...';
  static const String dashboardError = 'Failed to load dashboard';

  // ============================================================================
  // PROFILE
  // ============================================================================

  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String name = 'Name';
  static const String bio = 'Bio';
  static const String phone = 'Phone';
  static const String address = 'Address';

  // ============================================================================
  // SETTINGS
  // ============================================================================

  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // ============================================================================
  // OFFLINE
  // ============================================================================

  static const String offline = 'Offline';
  static const String offlineMessage = 'You are currently offline';
  static const String cachedData = 'Showing cached data';
  static const String noInternetConnection = 'No internet connection';

  // ============================================================================
  // EMPTY STATES
  // ============================================================================

  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String noItemsFound = 'No items found';

  // ============================================================================
  // DIALOGS
  // ============================================================================

  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String unsavedChanges = 'You have unsaved changes';
  static const String discardChanges = 'Discard changes?';

  // ============================================================================
  // FILTERS
  // ============================================================================

  static const String filterAll = 'All';
  static const String filterActive = 'Active';
  static const String filterCompleted = 'Completed';
  static const String filterUrgent = 'Urgent';
  static const String filterPending = 'Pending';

  // ============================================================================
  // STATUS
  // ============================================================================

  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String statusPending = 'Pending';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
}
