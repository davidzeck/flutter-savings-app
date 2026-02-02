import '../../core/constants/api_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/network_info.dart';
import '../models/dashboard_item.dart';
import '../services/api/api_service.dart';
import '../services/storage/local_storage_service.dart';

/// Repository for dashboard-related operations
///
/// Implements offline-first strategy:
/// 1. Return cached data immediately if available
/// 2. Fetch fresh data from API in background
/// 3. Update cache with fresh data
/// 4. Fall back to cache when offline
class DashboardRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;
  final NetworkInfo _networkInfo;

  // In-memory cache
  List<DashboardItem>? _cachedItems;
  DateTime? _lastFetchTime;

  DashboardRepository(
    this._apiService,
    this._localStorage,
    this._networkInfo,
  );

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Get dashboard items with offline-first strategy
  ///
  /// Returns cached data first, then fetches fresh data if online.
  /// Throws [CacheException] if no cached data and offline.
  Future<DashboardItemsResult> getDashboardItems({
    int page = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultPageSize,
    bool forceRefresh = false,
  }) async {
    // If force refresh and online, go straight to API
    if (forceRefresh && await _networkInfo.isConnected) {
      return await _fetchFromApi(page: page, limit: limit);
    }

    // Try in-memory cache first
    if (_cachedItems != null && !_isCacheExpired()) {
      return DashboardItemsResult(
        items: _cachedItems!,
        isFromCache: true,
        lastUpdated: _lastFetchTime,
      );
    }

    // Try local storage cache
    final localItems = _getLocalCache();
    if (localItems != null && localItems.isNotEmpty) {
      _cachedItems = localItems;

      // Fetch fresh data in background if online
      if (await _networkInfo.isConnected) {
        _refreshInBackground(page: page, limit: limit);
      }

      return DashboardItemsResult(
        items: localItems,
        isFromCache: true,
        lastUpdated: _lastFetchTime,
      );
    }

    // No cache - must fetch from API
    if (await _networkInfo.isConnected) {
      return await _fetchFromApi(page: page, limit: limit);
    }

    // Offline with no cache
    throw const NetworkException('No cached data available. Please connect to the internet.');
  }

  /// Refresh dashboard data from server
  ///
  /// Forces a fresh fetch from the API and updates cache.
  Future<DashboardItemsResult> refreshDashboard() async {
    return getDashboardItems(forceRefresh: true);
  }

  /// Get a single dashboard item by ID
  Future<DashboardItem> getDashboardItemById(String id) async {
    // Check in-memory cache first
    if (_cachedItems != null) {
      final cached = _cachedItems!.where((item) => item.id == id);
      if (cached.isNotEmpty) return cached.first;
    }

    if (!await _networkInfo.isConnected) {
      throw const NetworkException();
    }

    try {
      final response = await _apiService.getDashboardItem(id);
      final data = response.data as Map<String, dynamic>;
      return DashboardItem.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Failed to fetch item: $e');
    }
  }

  /// Get items filtered by status
  Future<List<DashboardItem>> getItemsByStatus(ItemStatus status) async {
    final result = await getDashboardItems();
    return result.items.where((item) => item.status == status).toList();
  }

  /// Get dashboard statistics
  DashboardStats getStats() {
    final items = _cachedItems ?? [];
    return DashboardStats.fromItems(items);
  }

  /// Clear all cached dashboard data
  Future<void> clearCache() async {
    _cachedItems = null;
    _lastFetchTime = null;
    await _localStorage.clearCache();
  }

  // ============================================================================
  // PRIVATE - API
  // ============================================================================

  /// Fetch dashboard items from the API
  Future<DashboardItemsResult> _fetchFromApi({
    int page = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiService.getDashboardItems(
        page: page,
        limit: limit,
      );

      final data = response.data;
      List<DashboardItem> items;

      if (data is List) {
        items = data
            .map((json) =>
                DashboardItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('items')) {
        final itemsList = data['items'] as List;
        items = itemsList
            .map((json) =>
                DashboardItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        items = _generateMockItems();
      }

      // Update caches
      _cachedItems = items;
      _lastFetchTime = DateTime.now();
      await _saveToLocalCache(items);

      return DashboardItemsResult(
        items: items,
        isFromCache: false,
        lastUpdated: _lastFetchTime,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      // If API fails, try to return cached data
      final cached = _getLocalCache();
      if (cached != null && cached.isNotEmpty) {
        return DashboardItemsResult(
          items: cached,
          isFromCache: true,
          lastUpdated: _lastFetchTime,
        );
      }

      // No cache and API failed - return mock data for demo
      final mockItems = _generateMockItems();
      _cachedItems = mockItems;
      _lastFetchTime = DateTime.now();
      await _saveToLocalCache(mockItems);

      return DashboardItemsResult(
        items: mockItems,
        isFromCache: false,
        lastUpdated: _lastFetchTime,
      );
    }
  }

  /// Refresh data in background (fire and forget)
  void _refreshInBackground({
    int page = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultPageSize,
  }) {
    _fetchFromApi(page: page, limit: limit).then((result) {
      _cachedItems = result.items;
    }).catchError((error) {
      // Silently fail - we already have cached data
    });
  }

  // ============================================================================
  // PRIVATE - CACHE
  // ============================================================================

  /// Save items to local storage via LocalStorageService
  Future<void> _saveToLocalCache(List<DashboardItem> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      await _localStorage.cacheItems(jsonList);
    } catch (e) {
      // Cache write failure is non-critical
    }
  }

  /// Get items from local storage cache
  List<DashboardItem>? _getLocalCache() {
    try {
      final jsonList = _localStorage.getCachedItems();
      if (jsonList == null) return null;

      return jsonList
          .map((json) => DashboardItem.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is expired
  bool _isCacheExpired() {
    if (_lastFetchTime == null) return true;
    final expiry = Duration(hours: ApiConstants.cacheDurationHours);
    return DateTime.now().difference(_lastFetchTime!) > expiry;
  }

  // ============================================================================
  // MOCK DATA (for demo/development)
  // ============================================================================

  /// Generate mock dashboard items for demo purposes
  List<DashboardItem> _generateMockItems() {
    final now = DateTime.now();
    return [
      DashboardItem(
        id: '1',
        title: 'Q4 Revenue Report',
        description: 'Compile and review quarterly revenue figures across all departments. Include YoY growth analysis and projections for next fiscal year.',
        status: ItemStatus.active,
        priority: ItemPriority.high,
        category: 'Finance',
        assignedTo: 'John Smith',
        createdAt: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 2)),
        progress: 65,
      ),
      DashboardItem(
        id: '2',
        title: 'Employee Onboarding Update',
        description: 'Update onboarding documentation and training materials for new hires. Add new compliance training modules for Q1.',
        status: ItemStatus.pending,
        priority: ItemPriority.medium,
        category: 'HR',
        assignedTo: 'Jane Doe',
        createdAt: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 7)),
        progress: 20,
      ),
      DashboardItem(
        id: '3',
        title: 'Server Migration Plan',
        description: 'Plan and execute migration from legacy on-prem servers to AWS cloud infrastructure. Includes database migration, DNS cutover, and rollback plan.',
        status: ItemStatus.active,
        priority: ItemPriority.urgent,
        category: 'Engineering',
        assignedTo: 'Mike Johnson',
        createdAt: now.subtract(const Duration(days: 10)),
        dueDate: now.subtract(const Duration(days: 1)),
        progress: 80,
      ),
      DashboardItem(
        id: '4',
        title: 'Client Proposal - Acme Corp',
        description: 'Draft and finalize the \$2.4M annual service proposal for Acme Corporation. Legal review completed, pending CFO sign-off.',
        status: ItemStatus.completed,
        priority: ItemPriority.high,
        category: 'Sales',
        assignedTo: 'Rachel Kim',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 1)),
        progress: 100,
      ),
      DashboardItem(
        id: '5',
        title: 'Security Audit Review',
        description: 'Review findings from the annual SOC 2 Type II security audit. Create remediation plan for 3 critical and 7 moderate findings.',
        status: ItemStatus.active,
        priority: ItemPriority.high,
        category: 'Security',
        assignedTo: 'Alex Brown',
        createdAt: now.subtract(const Duration(days: 7)),
        dueDate: now.add(const Duration(days: 5)),
        progress: 40,
      ),
      DashboardItem(
        id: '6',
        title: 'Marketing Campaign Launch',
        description: 'Coordinate the spring digital marketing campaign across Google Ads, LinkedIn, and email channels. Target: 50K impressions, 2% CTR.',
        status: ItemStatus.pending,
        priority: ItemPriority.medium,
        category: 'Marketing',
        assignedTo: 'Lisa Park',
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 14)),
        progress: 10,
      ),
      DashboardItem(
        id: '7',
        title: 'Budget Reallocation',
        description: 'Process the approved budget changes for the operations department. Reallocate \$150K from travel to digital infrastructure.',
        status: ItemStatus.cancelled,
        priority: ItemPriority.low,
        category: 'Finance',
        assignedTo: 'John Smith',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 3)),
        progress: 0,
      ),
      DashboardItem(
        id: '8',
        title: 'Vendor Contract Renewal',
        description: 'Negotiate and renew annual contracts with key technology vendors including Salesforce, AWS, and Datadog.',
        status: ItemStatus.active,
        priority: ItemPriority.medium,
        category: 'Operations',
        assignedTo: 'Jane Doe',
        createdAt: now.subtract(const Duration(days: 8)),
        dueDate: now.add(const Duration(days: 10)),
        progress: 55,
      ),
      DashboardItem(
        id: '9',
        title: 'Mobile App Beta Testing',
        description: 'Coordinate internal beta testing of the new enterprise mobile app. Collect feedback from 50+ employees across 5 departments.',
        status: ItemStatus.active,
        priority: ItemPriority.high,
        category: 'Engineering',
        assignedTo: 'David Chen',
        createdAt: now.subtract(const Duration(days: 4)),
        dueDate: now.add(const Duration(days: 8)),
        progress: 35,
      ),
      DashboardItem(
        id: '10',
        title: 'Annual Performance Reviews',
        description: 'Complete annual performance review cycle for Q4. 127 reviews remaining across engineering and operations teams.',
        status: ItemStatus.active,
        priority: ItemPriority.urgent,
        category: 'HR',
        assignedTo: 'Maria Garcia',
        createdAt: now.subtract(const Duration(days: 12)),
        dueDate: now.add(const Duration(days: 3)),
        progress: 72,
      ),
      DashboardItem(
        id: '11',
        title: 'Customer Satisfaction Survey',
        description: 'Analyze results from the Q3 NPS survey. Overall score: 67 (+4 from Q2). Prepare executive summary with action items.',
        status: ItemStatus.completed,
        priority: ItemPriority.medium,
        category: 'Customer Success',
        assignedTo: 'Tom Bradley',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(days: 2)),
        progress: 100,
      ),
      DashboardItem(
        id: '12',
        title: 'Data Pipeline Optimization',
        description: 'Optimize ETL data pipelines to reduce processing time by 40%. Current batch jobs taking 6+ hours nightly.',
        status: ItemStatus.pending,
        priority: ItemPriority.high,
        category: 'Engineering',
        assignedTo: 'Mike Johnson',
        createdAt: now.subtract(const Duration(days: 6)),
        dueDate: now.add(const Duration(days: 21)),
        progress: 5,
      ),
      DashboardItem(
        id: '13',
        title: 'Office Space Expansion',
        description: 'Coordinate the build-out of the new 4th floor office space. 2,500 sq ft for the growing data science team.',
        status: ItemStatus.active,
        priority: ItemPriority.medium,
        category: 'Facilities',
        assignedTo: 'Karen White',
        createdAt: now.subtract(const Duration(days: 30)),
        dueDate: now.add(const Duration(days: 45)),
        progress: 60,
      ),
      DashboardItem(
        id: '14',
        title: 'Compliance Training Rollout',
        description: 'Deploy mandatory GDPR and data privacy compliance training to all 450 employees. Deadline: end of quarter.',
        status: ItemStatus.pending,
        priority: ItemPriority.urgent,
        category: 'Legal',
        assignedTo: 'Alex Brown',
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 30)),
        progress: 0,
      ),
      DashboardItem(
        id: '15',
        title: 'Partner Integration - Stripe',
        description: 'Complete the Stripe payment gateway integration for the new billing module. API v3 migration required.',
        status: ItemStatus.completed,
        priority: ItemPriority.high,
        category: 'Engineering',
        assignedTo: 'David Chen',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 4)),
        progress: 100,
      ),
      DashboardItem(
        id: '16',
        title: 'Brand Guidelines Refresh',
        description: 'Update corporate brand guidelines to reflect the new logo and color palette. Distribute to all regional offices.',
        status: ItemStatus.completed,
        priority: ItemPriority.low,
        category: 'Marketing',
        assignedTo: 'Lisa Park',
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(days: 5)),
        progress: 100,
      ),
    ];
  }
}

// ============================================================================
// RESULT MODELS
// ============================================================================

/// Result wrapper for dashboard items fetch
class DashboardItemsResult {
  final List<DashboardItem> items;
  final bool isFromCache;
  final DateTime? lastUpdated;

  const DashboardItemsResult({
    required this.items,
    required this.isFromCache,
    this.lastUpdated,
  });
}

/// Dashboard statistics computed from items
class DashboardStats {
  final int totalItems;
  final int activeItems;
  final int pendingItems;
  final int completedItems;
  final int overdueItems;
  final int urgentItems;

  const DashboardStats({
    required this.totalItems,
    required this.activeItems,
    required this.pendingItems,
    required this.completedItems,
    required this.overdueItems,
    required this.urgentItems,
  });

  factory DashboardStats.fromItems(List<DashboardItem> items) {
    return DashboardStats(
      totalItems: items.length,
      activeItems:
          items.where((i) => i.status == ItemStatus.active).length,
      pendingItems:
          items.where((i) => i.status == ItemStatus.pending).length,
      completedItems:
          items.where((i) => i.status == ItemStatus.completed).length,
      overdueItems: items.where((i) => i.isOverdue).length,
      urgentItems: items.where((i) => i.isHighPriority).length,
    );
  }
}
