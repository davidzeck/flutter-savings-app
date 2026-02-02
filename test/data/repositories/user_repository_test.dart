import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enterprise_flutter_mobile_app/core/exceptions/app_exceptions.dart';
import 'package:enterprise_flutter_mobile_app/core/utils/network_info.dart';
import 'package:enterprise_flutter_mobile_app/data/models/user.dart';
import 'package:enterprise_flutter_mobile_app/data/repositories/user_repository.dart';
import 'package:enterprise_flutter_mobile_app/data/services/api/api_service.dart';
import 'package:enterprise_flutter_mobile_app/data/services/storage/local_storage_service.dart';

// Mocks
class MockApiService extends Mock implements ApiService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late UserRepository repository;
  late MockApiService mockApiService;
  late MockLocalStorageService mockLocalStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockApiService = MockApiService();
    mockLocalStorage = MockLocalStorageService();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepository(
      mockApiService,
      mockLocalStorage,
      mockNetworkInfo,
    );
  });

  // Helper to create a test user JSON
  Map<String, dynamic> testUserJson() => {
        'id': 'user-1',
        'email': 'test@example.com',
        'name': 'Test User',
        'bio': 'A test user',
        'phone': '+1234567890',
      };

  User testUser() => User.fromJson(testUserJson());

  group('UserRepository', () {
    // =========================================================================
    // LOGIN
    // =========================================================================
    group('login', () {
      test('should return User when API login succeeds', () async {
        // Arrange
        final responseData = {
          'user': testUserJson(),
          'token': 'test-token-123',
        };
        when(() => mockApiService.login(any(), any())).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.saveToken(any()))
            .thenAnswer((_) async {});
        when(() => mockLocalStorage.saveUserData(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.login('test@example.com', 'password');

        // Assert
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');
        verify(() => mockLocalStorage.saveToken('test-token-123')).called(1);
        verify(() => mockLocalStorage.saveUserData(any())).called(1);
      });

      test('should fall back to demo login when API fails', () async {
        // Arrange
        when(() => mockApiService.login(any(), any()))
            .thenThrow(const NetworkException());
        when(() => mockLocalStorage.saveToken(any()))
            .thenAnswer((_) async {});
        when(() => mockLocalStorage.saveUserData(any()))
            .thenAnswer((_) async {});

        // Act
        final result =
            await repository.login('demo@example.com', 'password123');

        // Assert
        expect(result.name, 'Demo User');
        expect(result.email, 'demo@example.com');
        verify(() => mockLocalStorage.saveToken(any())).called(1);
      });

      test('should throw InvalidCredentialsException for wrong demo creds',
          () async {
        // Arrange
        when(() => mockApiService.login(any(), any()))
            .thenThrow(const NetworkException());

        // Act & Assert
        expect(
          () => repository.login('wrong@example.com', 'wrong'),
          throwsA(isA<InvalidCredentialsException>()),
        );
      });
    });

    // =========================================================================
    // LOGOUT
    // =========================================================================
    group('logout', () {
      test('should clear local data even if API logout fails', () async {
        // Arrange
        when(() => mockApiService.logout())
            .thenThrow(const NetworkException());
        when(() => mockLocalStorage.clearToken())
            .thenAnswer((_) async {});
        when(() => mockLocalStorage.clearUserData())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocalStorage.clearToken()).called(1);
        verify(() => mockLocalStorage.clearUserData()).called(1);
      });

      test('should call API logout and clear local data on success', () async {
        // Arrange
        when(() => mockApiService.logout()).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.clearToken())
            .thenAnswer((_) async {});
        when(() => mockLocalStorage.clearUserData())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockApiService.logout()).called(1);
        verify(() => mockLocalStorage.clearToken()).called(1);
        verify(() => mockLocalStorage.clearUserData()).called(1);
      });
    });

    // =========================================================================
    // IS AUTHENTICATED
    // =========================================================================
    group('isAuthenticated', () {
      test('should return true when token exists', () async {
        when(() => mockLocalStorage.hasToken())
            .thenAnswer((_) async => true);

        final result = await repository.isAuthenticated();
        expect(result, true);
      });

      test('should return false when no token', () async {
        when(() => mockLocalStorage.hasToken())
            .thenAnswer((_) async => false);

        final result = await repository.isAuthenticated();
        expect(result, false);
      });
    });

    // =========================================================================
    // GET CURRENT USER
    // =========================================================================
    group('getCurrentUser', () {
      test('should return cached user from local storage', () async {
        // Arrange
        when(() => mockLocalStorage.getUserData())
            .thenReturn(testUserJson());
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.name, 'Test User');
      });

      test('should return null when no cached data and offline', () async {
        // Arrange
        when(() => mockLocalStorage.getUserData()).thenReturn(null);
        when(() => mockLocalStorage.hasToken())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('should return null when authenticated but offline and no cache',
          () async {
        // Arrange
        when(() => mockLocalStorage.getUserData()).thenReturn(null);
        when(() => mockLocalStorage.hasToken())
            .thenAnswer((_) async => true);
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    // =========================================================================
    // UPDATE PROFILE
    // =========================================================================
    group('updateProfile', () {
      test('should throw NetworkException when offline', () async {
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => false);

        expect(
          () => repository.updateProfile(name: 'New Name'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should return updated user on success', () async {
        // Arrange
        final updatedJson = testUserJson()..['name'] = 'Updated Name';
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => true);
        when(() => mockApiService.updateProfile(
              name: any(named: 'name'),
              bio: any(named: 'bio'),
              avatarUrl: any(named: 'avatarUrl'),
            )).thenAnswer(
          (_) async => Response(
            data: updatedJson,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.saveUserData(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateProfile(name: 'Updated Name');

        // Assert
        expect(result.name, 'Updated Name');
        verify(() => mockLocalStorage.saveUserData(any())).called(1);
      });
    });
  });
}
