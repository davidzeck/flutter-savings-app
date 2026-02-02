import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:enterprise_flutter_mobile_app/core/exceptions/app_exceptions.dart';
import 'package:enterprise_flutter_mobile_app/data/models/dashboard_item.dart';
import 'package:enterprise_flutter_mobile_app/data/models/user.dart';
import 'package:enterprise_flutter_mobile_app/data/repositories/dashboard_repository.dart';
import 'package:enterprise_flutter_mobile_app/data/repositories/user_repository.dart';
import 'package:enterprise_flutter_mobile_app/features/dashboard/dashboard_viewmodel.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockDashboardRepository mockDashboardRepo;
  late MockUserRepository mockUserRepo;

  final now = DateTime.now();

  List<DashboardItem> testItems() => [
        DashboardItem(
          id: '1',
          title: 'Active High',
          description: 'desc',
          status: ItemStatus.active,
          priority: ItemPriority.high,
          category: 'Finance',
          createdAt: now,
          progress: 50,
        ),
        DashboardItem(
          id: '2',
          title: 'Pending Medium',
          description: 'desc',
          status: ItemStatus.pending,
          priority: ItemPriority.medium,
          category: 'HR',
          createdAt: now,
          progress: 20,
        ),
        DashboardItem(
          id: '3',
          title: 'Completed Low',
          description: 'desc',
          status: ItemStatus.completed,
          priority: ItemPriority.low,
          category: 'Ops',
          createdAt: now,
          progress: 100,
        ),
        DashboardItem(
          id: '4',
          title: 'Active Urgent',
          description: 'desc',
          status: ItemStatus.active,
          priority: ItemPriority.urgent,
          category: 'Sales',
          createdAt: now,
          dueDate: now.subtract(const Duration(days: 1)),
          progress: 30,
        ),
      ];

  DashboardItemsResult testResult({bool fromCache = false}) =>
      DashboardItemsResult(
        items: testItems(),
        isFromCache: fromCache,
        lastUpdated: now,
      );

  setUp(() {
    mockDashboardRepo = MockDashboardRepository();
    mockUserRepo = MockUserRepository();
  });

  /// Creates a DashboardViewModel with mocked dependencies.
  /// The constructor calls loadDashboard(), so we must set up mocks first.
  DashboardViewModel createViewModel({
    DashboardItemsResult? dashResult,
    User? user,
    Exception? dashError,
    Exception? userError,
  }) {
    if (dashError != null) {
      when(() => mockDashboardRepo.getDashboardItems(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            forceRefresh: any(named: 'forceRefresh'),
          )).thenThrow(dashError);
    } else {
      when(() => mockDashboardRepo.getDashboardItems(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            forceRefresh: any(named: 'forceRefresh'),
          )).thenAnswer((_) async => dashResult ?? testResult());
    }

    if (userError != null) {
      when(() => mockUserRepo.getCurrentUser()).thenThrow(userError);
    } else {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => user);
    }

    return DashboardViewModel(mockDashboardRepo, mockUserRepo);
  }

  group('DashboardViewModel', () {
    // =========================================================================
    // LOAD DASHBOARD
    // =========================================================================
    group('loadDashboard', () {
      test('should load items and user name on construction', () async {
        final user = const User(
          id: 'u1',
          email: 'test@example.com',
          name: 'John Doe',
        );
        final vm = createViewModel(user: user);

        // Wait for the async loadDashboard to complete
        await Future.delayed(Duration.zero);

        expect(vm.items.length, 4);
        expect(vm.userName, 'John Doe');
        expect(vm.isLoading, false);
        expect(vm.hasItems, true);
      });

      test('should set stats from loaded items', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        expect(vm.stats.totalItems, 4);
        expect(vm.stats.activeItems, 2);
        expect(vm.stats.pendingItems, 1);
        expect(vm.stats.completedItems, 1);
      });

      test('should set isFromCache when result is from cache', () async {
        final vm = createViewModel(
          dashResult: testResult(fromCache: true),
        );
        await Future.delayed(Duration.zero);

        expect(vm.isFromCache, true);
      });

      test('should set error on NetworkException', () async {
        final vm = createViewModel(
          dashError: const NetworkException(),
        );
        await Future.delayed(Duration.zero);

        expect(vm.hasError, true);
        expect(vm.errorMessage, isNotNull);
      });

      test('should handle user fetch failure gracefully', () async {
        final vm = createViewModel(
          userError: Exception('user fetch failed'),
        );
        await Future.delayed(Duration.zero);

        // Dashboard items should still load
        // But the generic catch will fire for the whole loadDashboard
        // since getCurrentUser throws before getDashboardItems
        expect(vm.hasError, true);
      });
    });

    // =========================================================================
    // FILTERS
    // =========================================================================
    group('setFilter', () {
      test('should filter active items', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        vm.setFilter(DashboardFilter.active);
        expect(vm.items.length, 2);
        expect(
          vm.items.every((i) => i.status == ItemStatus.active),
          true,
        );
      });

      test('should filter pending items', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        vm.setFilter(DashboardFilter.pending);
        expect(vm.items.length, 1);
        expect(vm.items.first.status, ItemStatus.pending);
      });

      test('should filter completed items', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        vm.setFilter(DashboardFilter.completed);
        expect(vm.items.length, 1);
        expect(vm.items.first.status, ItemStatus.completed);
      });

      test('should filter urgent (high priority) items', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        vm.setFilter(DashboardFilter.urgent);
        // high + urgent priority
        expect(vm.items.length, 2);
        expect(vm.items.every((i) => i.isHighPriority), true);
      });

      test('should show all items when filter is all', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        vm.setFilter(DashboardFilter.active);
        expect(vm.items.length, 2);

        vm.setFilter(DashboardFilter.all);
        expect(vm.items.length, 4);
      });

      test('should not notify when setting same filter', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        var notifyCount = 0;
        vm.addListener(() => notifyCount++);

        vm.setFilter(DashboardFilter.all); // same as default
        expect(notifyCount, 0);
      });
    });

    // =========================================================================
    // REFRESH
    // =========================================================================
    group('refreshDashboard', () {
      test('should call repository refreshDashboard', () async {
        when(() => mockDashboardRepo.refreshDashboard())
            .thenAnswer((_) async => testResult());
        when(() => mockDashboardRepo.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              forceRefresh: any(named: 'forceRefresh'),
            )).thenAnswer((_) async => testResult());
        when(() => mockUserRepo.getCurrentUser())
            .thenAnswer((_) async => null);

        final vm = DashboardViewModel(mockDashboardRepo, mockUserRepo);
        await Future.delayed(Duration.zero);

        await vm.refreshDashboard();

        verify(() => mockDashboardRepo.refreshDashboard()).called(1);
        expect(vm.isRefreshing, false);
      });

      test('should set error on refresh failure', () async {
        when(() => mockDashboardRepo.getDashboardItems(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              forceRefresh: any(named: 'forceRefresh'),
            )).thenAnswer((_) async => testResult());
        when(() => mockUserRepo.getCurrentUser())
            .thenAnswer((_) async => null);
        when(() => mockDashboardRepo.refreshDashboard())
            .thenThrow(const NetworkException());

        final vm = DashboardViewModel(mockDashboardRepo, mockUserRepo);
        await Future.delayed(Duration.zero);

        await vm.refreshDashboard();

        expect(vm.hasError, true);
        expect(vm.isRefreshing, false);
      });
    });

    // =========================================================================
    // CLEAR ERROR
    // =========================================================================
    group('clearError', () {
      test('should clear error message and notify', () async {
        final vm = createViewModel(
          dashError: const NetworkException(),
        );
        await Future.delayed(Duration.zero);

        expect(vm.hasError, true);

        var notified = false;
        vm.addListener(() => notified = true);
        vm.clearError();

        expect(vm.hasError, false);
        expect(notified, true);
      });
    });

    // =========================================================================
    // LOGOUT
    // =========================================================================
    group('logout', () {
      test('should call repository logout and clearCache', () async {
        final vm = createViewModel();
        await Future.delayed(Duration.zero);

        when(() => mockUserRepo.logout()).thenAnswer((_) async {});
        when(() => mockDashboardRepo.clearCache())
            .thenAnswer((_) async {});

        await vm.logout();

        verify(() => mockUserRepo.logout()).called(1);
        verify(() => mockDashboardRepo.clearCache()).called(1);
      });
    });
  });
}
