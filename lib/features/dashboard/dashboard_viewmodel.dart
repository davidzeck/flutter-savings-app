import 'package:flutter/foundation.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../data/models/dashboard_item.dart';
import '../../data/models/user.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Filter options for dashboard items
enum DashboardFilter {
  all,
  active,
  pending,
  completed,
  urgent,
}

/// ViewModel for Dashboard screen
///
/// Manages dashboard state, filtering, refresh, and data loading.
class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  final UserRepository _userRepository;

  DashboardViewModel(
    this._dashboardRepository,
    this._userRepository,
  ) {
    loadDashboard();
  }

  // ============================================================================
  // STATE
  // ============================================================================

  List<DashboardItem> _allItems = [];
  List<DashboardItem> _filteredItems = [];
  DashboardStats _stats = const DashboardStats(
    totalItems: 0,
    activeItems: 0,
    pendingItems: 0,
    completedItems: 0,
    overdueItems: 0,
    urgentItems: 0,
  );
  DashboardFilter _currentFilter = DashboardFilter.all;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isFromCache = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  String _userName = '';
  User? _currentUser;

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<DashboardItem> get items => _filteredItems;
  DashboardStats get stats => _stats;
  DashboardFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isFromCache => _isFromCache;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  String get userName => _userName;
  User? get currentUser => _currentUser;
  bool get hasItems => _filteredItems.isNotEmpty;
  bool get hasError => _errorMessage != null;

  // ============================================================================
  // COMMANDS
  // ============================================================================

  /// Load dashboard data
  Future<void> loadDashboard() async {
    _setLoading(true);
    _clearError();

    // Load user separately so dashboard errors don't lose user data
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _userName = user.name;
      }
    } catch (_) {
      // User fetch failed — continue loading dashboard
    }

    try {
      // Load dashboard items
      final result = await _dashboardRepository.getDashboardItems();
      _allItems = result.items;
      _isFromCache = result.isFromCache;
      _lastUpdated = result.lastUpdated;
      _stats = DashboardStats.fromItems(_allItems);
      _applyFilter();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = AppStrings.dashboardError;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh dashboard data (pull-to-refresh)
  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _dashboardRepository.refreshDashboard();
      _allItems = result.items;
      _isFromCache = result.isFromCache;
      _lastUpdated = result.lastUpdated;
      _stats = DashboardStats.fromItems(_allItems);
      _applyFilter();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = AppStrings.dashboardError;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Set filter and update displayed items
  void setFilter(DashboardFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout current user
  Future<void> logout() async {
    await _userRepository.logout();
    await _dashboardRepository.clearCache();
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Apply the current filter to items
  void _applyFilter() {
    switch (_currentFilter) {
      case DashboardFilter.all:
        _filteredItems = List.from(_allItems);
        break;
      case DashboardFilter.active:
        _filteredItems = _allItems
            .where((item) => item.status == ItemStatus.active)
            .toList();
        break;
      case DashboardFilter.pending:
        _filteredItems = _allItems
            .where((item) => item.status == ItemStatus.pending)
            .toList();
        break;
      case DashboardFilter.completed:
        _filteredItems = _allItems
            .where((item) => item.status == ItemStatus.completed)
            .toList();
        break;
      case DashboardFilter.urgent:
        _filteredItems =
            _allItems.where((item) => item.isHighPriority).toList();
        break;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

}
