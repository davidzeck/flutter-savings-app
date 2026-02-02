import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/repositories/dashboard_repository.dart';

/// Horizontal scrollable stats cards for the dashboard
class DashboardStatsRow extends StatelessWidget {
  final DashboardStats stats;

  const DashboardStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingScreen,
        ),
        children: [
          _StatCard(
            label: 'Total',
            value: stats.totalItems.toString(),
            icon: Icons.dashboard_outlined,
            color: AppColors.primary,
          ),
          _StatCard(
            label: 'Active',
            value: stats.activeItems.toString(),
            icon: Icons.play_circle_outline,
            color: AppColors.info,
          ),
          _StatCard(
            label: 'Pending',
            value: stats.pendingItems.toString(),
            icon: Icons.pending_outlined,
            color: AppColors.warning,
          ),
          _StatCard(
            label: 'Completed',
            value: stats.completedItems.toString(),
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
          _StatCard(
            label: 'Overdue',
            value: stats.overdueItems.toString(),
            icon: Icons.error_outline,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
