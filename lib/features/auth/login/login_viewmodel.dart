import 'package:flutter/foundation.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';

/// ViewModel for Login screen
///
/// Manages login state, validation, and authentication logic
class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  LoginViewModel(this._userRepository);

  // ============================================================================
  // STATE
  // ============================================================================

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Validation errors
  String? _emailError;
  String? _passwordError;

  // ============================================================================
  // GETTERS
  // ============================================================================

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  /// Check if form is valid
  bool get isFormValid {
    return _email.isNotEmpty &&
        _password.isNotEmpty &&
        _emailError == null &&
        _passwordError == null;
  }

  /// Check if login was successful
  bool get isAuthenticated => _currentUser != null;

  // ============================================================================
  // COMMANDS
  // ============================================================================

  /// Update email field
  void updateEmail(String email) {
    _email = email.trim();
    _emailError = _validateEmail(_email);
    _clearError();
    notifyListeners();
  }

  /// Update password field
  void updatePassword(String password) {
    _password = password;
    _passwordError = _validatePassword(_password);
    _clearError();
    notifyListeners();
  }

  /// Perform login
  Future<void> login() async {
    // Validate form
    if (!_validateForm()) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Attempt login
      final user = await _userRepository.login(_email, _password);
      _currentUser = user;

      // Success - view will navigate based on isAuthenticated
      print('Login successful: ${user.name}');
    } on InvalidCredentialsException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } on TimeoutException catch (e) {
      _errorMessage = e.message;
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = AppStrings.errorGeneric;
      print('Unexpected login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate entire form
  bool _validateForm() {
    _emailError = _validateEmail(_email);
    _passwordError = _validatePassword(_password);

    if (_emailError != null) {
      _errorMessage = _emailError;
      return false;
    }

    if (_passwordError != null) {
      _errorMessage = _passwordError;
      return false;
    }

    return true;
  }

  /// Validate email
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return AppStrings.emailRequired;
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  /// Validate password
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (password.length < 6) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
