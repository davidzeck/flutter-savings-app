import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/dashboard_item.dart';
import 'dashboard_viewmodel.dart';
import 'item_detail_view.dart';
import 'widgets/dashboard_item_card.dart';
import 'widgets/dashboard_stats_card.dart';
import 'widgets/shimmer_loading.dart';

/// Full dashboard screen with stats, filters, and item list
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: _buildAppBar(context, viewModel),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return AppBar(
      toolbarHeight: viewModel.userName.isNotEmpty ? 64 : kToolbarHeight,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(AppStrings.dashboard),
          if (viewModel.userName.isNotEmpty)
            Text(
              'Welcome, ${viewModel.userName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      actions: [
        // Offline indicator
        if (viewModel.isFromCache)
          Tooltip(
            message: AppStrings.cachedData,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Cached',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(width: AppDimensions.sm),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return const DashboardShimmerLoading();
    }

    // Error state with no data
    if (viewModel.hasError && !viewModel.hasItems) {
      return _buildErrorState(context, viewModel);
    }

    // Main content with pull-to-refresh
    return RefreshIndicator(
      onRefresh: viewModel.refreshDashboard,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Error banner (if error but has cached data)
          if (viewModel.hasError)
            SliverToBoxAdapter(
              child: _buildErrorBanner(context, viewModel),
            ),

          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.md,
                bottom: AppDimensions.sm,
              ),
              child: DashboardStatsRow(stats: viewModel.stats),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: _buildFilterChips(context, viewModel),
          ),

          // Items list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingScreen,
                vertical: AppDimensions.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${viewModel.items.length} items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (viewModel.isRefreshing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),

          // Items list or empty state
          if (viewModel.hasItems)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingScreen,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = viewModel.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.sm,
                      ),
                      child: DashboardItemCard(
                        item: item,
                        onTap: () => _showItemDetail(context, item),
                      ),
                    );
                  },
                  childCount: viewModel.items.length,
                ),
              ),
            )
          else
            SliverFillRemaining(
              child: _buildEmptyState(context, viewModel),
            ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.xxl),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // FILTER CHIPS
  // ============================================================================

  Widget _buildFilterChips(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingScreen,
        ),
        children: DashboardFilter.values.map((filter) {
          final isSelected = viewModel.currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.sm),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (_) => viewModel.setFilter(filter),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(DashboardFilter filter) {
    switch (filter) {
      case DashboardFilter.all:
        return AppStrings.filterAll;
      case DashboardFilter.active:
        return AppStrings.filterActive;
      case DashboardFilter.pending:
        return AppStrings.filterPending;
      case DashboardFilter.completed:
        return AppStrings.filterCompleted;
      case DashboardFilter.urgent:
        return AppStrings.filterUrgent;
    }
  }

  // ============================================================================
  // STATES
  // ============================================================================

  Widget _buildErrorState(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingScreen),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              AppStrings.dashboardError,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              viewModel.errorMessage ?? AppStrings.errorGeneric,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: viewModel.loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            AppStrings.noDashboardItems,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.sm),
          if (viewModel.currentFilter != DashboardFilter.all)
            TextButton(
              onPressed: () => viewModel.setFilter(DashboardFilter.all),
              child: const Text('Show all items'),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.paddingScreen,
        AppDimensions.sm,
        AppDimensions.paddingScreen,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              '${viewModel.errorMessage} Showing cached data.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: viewModel.clearError,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  void _showItemDetail(BuildContext context, DashboardItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailView(item: item),
      ),
    );
  }
}
