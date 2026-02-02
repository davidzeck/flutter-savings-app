import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enterprise_flutter_mobile_app/core/exceptions/app_exceptions.dart';
import 'package:enterprise_flutter_mobile_app/core/utils/network_info.dart';
import 'package:enterprise_flutter_mobile_app/data/models/dashboard_item.dart';
import 'package:enterprise_flutter_mobile_app/data/repositories/dashboard_repository.dart';
import 'package:enterprise_flutter_mobile_app/data/services/api/api_service.dart';
import 'package:enterprise_flutter_mobile_app/data/services/storage/local_storage_service.dart';

class MockApiService extends Mock implements ApiService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late DashboardRepository repository;
  late MockApiService mockApiService;
  late MockLocalStorageService mockLocalStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockApiService = MockApiService();
    mockLocalStorage = MockLocalStorageService();
    mockNetworkInfo = MockNetworkInfo();
    repository = DashboardRepository(
      mockApiService,
      mockLocalStorage,
      mockNetworkInfo,
    );
  });

  List<Map<String, dynamic>> testItemsJson() => [
        {
          'id': '1',
          'title': 'Test Item 1',
          'description': 'Description 1',
          'status': 'active',
          'priority': 'high',
          'category': 'Finance',
          'assigned_to': 'John',
          'created_at': DateTime.now().toIso8601String(),
          'progress': 50,
        },
        {
          'id': '2',
          'title': 'Test Item 2',
          'description': 'Description 2',
          'status': 'pending',
          'priority': 'medium',
          'category': 'HR',
          'created_at': DateTime.now().toIso8601String(),
          'progress': 20,
        },
      ];

  group('DashboardRepository', () {
    // =========================================================================
    // GET DASHBOARD ITEMS
    // =========================================================================
    group('getDashboardItems', () {
      test('should fetch from API when online and no cache', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => true);
        when(() => mockLocalStorage.getCachedItems()).thenReturn(null);
        when(() => mockApiService.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => Response(
            data: testItemsJson(),
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.cacheItems(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getDashboardItems();

        // Assert
        expect(result.items.length, 2);
        expect(result.isFromCache, false);
        expect(result.items[0].title, 'Test Item 1');
      });

      test('should return local cache when available and not expired',
          () async {
        // First, populate the in-memory cache by fetching from API
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => true);
        when(() => mockLocalStorage.getCachedItems()).thenReturn(null);
        when(() => mockApiService.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => Response(
            data: testItemsJson(),
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.cacheItems(any()))
            .thenAnswer((_) async {});

        // Populate cache
        await repository.getDashboardItems();

        // Act - second call should use in-memory cache
        final result = await repository.getDashboardItems();

        // Assert
        expect(result.items.length, 2);
        expect(result.isFromCache, true);
      });

      test('should return mock items when API fails and no cache', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => true);
        when(() => mockLocalStorage.getCachedItems()).thenReturn(null);
        when(() => mockApiService.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('API error'));
        when(() => mockLocalStorage.cacheItems(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getDashboardItems();

        // Assert
        expect(result.items, isNotEmpty);
        // Mock items have 16 items
        expect(result.items.length, 16);
      });

      test('should throw NetworkException when offline with no cache',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => false);
        when(() => mockLocalStorage.getCachedItems()).thenReturn(null);

        // Act & Assert
        expect(
          () => repository.getDashboardItems(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should return local storage cache when offline', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => false);
        when(() => mockLocalStorage.getCachedItems())
            .thenReturn(testItemsJson());

        // Act
        final result = await repository.getDashboardItems();

        // Assert
        expect(result.items.length, 2);
        expect(result.isFromCache, true);
      });

      test('should force refresh from API when forceRefresh is true',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => true);
        when(() => mockApiService.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => Response(
            data: testItemsJson(),
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.cacheItems(any()))
            .thenAnswer((_) async {});

        // Act
        final result =
            await repository.getDashboardItems(forceRefresh: true);

        // Assert
        expect(result.isFromCache, false);
        verify(() => mockApiService.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).called(1);
      });
    });

    // =========================================================================
    // GET STATS
    // =========================================================================
    group('getStats', () {
      test('should return empty stats when no cached items', () {
        final stats = repository.getStats();
        expect(stats.totalItems, 0);
        expect(stats.activeItems, 0);
      });

      test('should compute stats from cached items', () async {
        // Populate cache first
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((_) async => true);
        when(() => mockLocalStorage.getCachedItems()).thenReturn(null);
        when(() => mockApiService.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => Response(
            data: testItemsJson(),
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );
        when(() => mockLocalStorage.cacheItems(any()))
            .thenAnswer((_) async {});

        await repository.getDashboardItems();

        // Act
        final stats = repository.getStats();

        // Assert
        expect(stats.totalItems, 2);
        expect(stats.activeItems, 1);
        expect(stats.pendingItems, 1);
      });
    });

    // =========================================================================
    // CLEAR CACHE
    // =========================================================================
    group('clearCache', () {
      test('should clear local storage and in-memory cache', () async {
        when(() => mockLocalStorage.clearCache())
            .thenAnswer((_) async {});

        await repository.clearCache();

        verify(() => mockLocalStorage.clearCache()).called(1);
      });
    });

    // =========================================================================
    // DASHBOARD STATS MODEL
    // =========================================================================
    group('DashboardStats.fromItems', () {
      test('should correctly compute stats from items', () {
        final now = DateTime.now();
        final items = [
          DashboardItem(
            id: '1',
            title: 'Active',
            description: 'desc',
            status: ItemStatus.active,
            priority: ItemPriority.high,
            category: 'Test',
            createdAt: now,
            progress: 50,
          ),
          DashboardItem(
            id: '2',
            title: 'Pending',
            description: 'desc',
            status: ItemStatus.pending,
            priority: ItemPriority.urgent,
            category: 'Test',
            createdAt: now,
            progress: 10,
          ),
          DashboardItem(
            id: '3',
            title: 'Completed',
            description: 'desc',
            status: ItemStatus.completed,
            priority: ItemPriority.low,
            category: 'Test',
            createdAt: now,
            progress: 100,
          ),
          DashboardItem(
            id: '4',
            title: 'Overdue',
            description: 'desc',
            status: ItemStatus.active,
            priority: ItemPriority.medium,
            category: 'Test',
            createdAt: now.subtract(const Duration(days: 10)),
            dueDate: now.subtract(const Duration(days: 1)),
            progress: 30,
          ),
        ];

        final stats = DashboardStats.fromItems(items);

        expect(stats.totalItems, 4);
        expect(stats.activeItems, 2);
        expect(stats.pendingItems, 1);
        expect(stats.completedItems, 1);
        expect(stats.overdueItems, 1);
        // high + urgent = 2
        expect(stats.urgentItems, 2);
      });
    });
  });
}
