import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enterprise_flutter_mobile_app/core/exceptions/app_exceptions.dart';
import 'package:enterprise_flutter_mobile_app/data/models/user.dart';
import 'package:enterprise_flutter_mobile_app/data/repositories/user_repository.dart';
import 'package:enterprise_flutter_mobile_app/features/auth/login/login_viewmodel.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late LoginViewModel viewModel;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    viewModel = LoginViewModel(mockUserRepository);
  });

  User testUser() => const User(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
      );

  group('LoginViewModel', () {
    // =========================================================================
    // VALIDATION
    // =========================================================================
    group('validation', () {
      test('isFormValid should be false when fields are empty', () {
        expect(viewModel.isFormValid, false);
      });

      test('should set email error for invalid email', () {
        viewModel.updateEmail('invalid');
        expect(viewModel.emailError, isNotNull);
      });

      test('should clear email error for valid email', () {
        viewModel.updateEmail('test@example.com');
        expect(viewModel.emailError, isNull);
      });

      test('should set password error for short password', () {
        viewModel.updatePassword('12345');
        expect(viewModel.passwordError, isNotNull);
      });

      test('should clear password error for valid password', () {
        viewModel.updatePassword('123456');
        expect(viewModel.passwordError, isNull);
      });

      test('isFormValid should be true with valid inputs', () {
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');
        expect(viewModel.isFormValid, true);
      });
    });

    // =========================================================================
    // LOGIN
    // =========================================================================
    group('login', () {
      test('should not call repository when form is invalid', () async {
        // Empty fields
        await viewModel.login();

        verifyNever(() => mockUserRepository.login(any(), any()));
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should set isLoading during login', () async {
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');

        when(() => mockUserRepository.login(any(), any())).thenAnswer(
          (_) async {
            // Verify loading is true during the call
            expect(viewModel.isLoading, true);
            return testUser();
          },
        );

        await viewModel.login();

        expect(viewModel.isLoading, false);
      });

      test('should set currentUser on successful login', () async {
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');

        when(() => mockUserRepository.login(any(), any()))
            .thenAnswer((_) async => testUser());

        await viewModel.login();

        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.isAuthenticated, true);
        expect(viewModel.errorMessage, isNull);
      });

      test('should set error on InvalidCredentialsException', () async {
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');

        when(() => mockUserRepository.login(any(), any()))
            .thenThrow(const InvalidCredentialsException());

        await viewModel.login();

        expect(viewModel.currentUser, isNull);
        expect(viewModel.isAuthenticated, false);
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.errorMessage, contains('Invalid'));
      });

      test('should set error on NetworkException', () async {
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');

        when(() => mockUserRepository.login(any(), any()))
            .thenThrow(const NetworkException());

        await viewModel.login();

        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isAuthenticated, false);
      });

      test('should set generic error on unexpected exception', () async {
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');

        when(() => mockUserRepository.login(any(), any()))
            .thenThrow(Exception('unexpected'));

        await viewModel.login();

        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isAuthenticated, false);
      });
    });

    // =========================================================================
    // CLEAR ERROR
    // =========================================================================
    group('clearError', () {
      test('should clear error message', () async {
        // Trigger an error first
        viewModel.updateEmail('test@example.com');
        viewModel.updatePassword('password123');
        when(() => mockUserRepository.login(any(), any()))
            .thenThrow(const NetworkException());
        await viewModel.login();

        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();
        expect(viewModel.errorMessage, isNull);
      });
    });

    // =========================================================================
    // NOTIFY LISTENERS
    // =========================================================================
    group('notifyListeners', () {
      test('should notify on email update', () {
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.updateEmail('test@example.com');
        expect(notified, true);
      });

      test('should notify on password update', () {
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.updatePassword('password');
        expect(notified, true);
      });
    });
  });
}
