import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/repositories/dashboard_repository.dart';

/// Compact stats grid for the dashboard — fits on screen without scrolling
class DashboardStatsRow extends StatelessWidget {
  final DashboardStats stats;

  const DashboardStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingScreen,
      ),
      child: Column(
        children: [
          // Top row: Total (wide) + Overdue
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _StatCard(
                  label: 'Total',
                  value: stats.totalItems.toString(),
                  icon: Icons.dashboard_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _StatCard(
                  label: 'Overdue',
                  value: stats.overdueItems.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          // Bottom row: Active + Pending + Completed
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  value: stats.activeItems.toString(),
                  icon: Icons.play_circle_outline,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _StatCard(
                  label: 'Pending',
                  value: stats.pendingItems.toString(),
                  icon: Icons.pending_outlined,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _StatCard(
                  label: 'Done',
                  value: stats.completedItems.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
