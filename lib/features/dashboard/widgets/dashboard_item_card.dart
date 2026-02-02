import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/dashboard_item.dart';

/// Card widget for displaying a single dashboard item
class DashboardItemCard extends StatelessWidget {
  final DashboardItem item;
  final VoidCallback? onTap;

  const DashboardItemCard({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'item-card-${item.id}',
      child: Card(
      elevation: AppDimensions.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: item.isOverdue
            ? const BorderSide(color: AppColors.error, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Category + Priority + Status
              _buildTopRow(context),
              const SizedBox(height: AppDimensions.sm),

              // Title
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.xs),

              // Description
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.md),

              // Progress bar
              _buildProgressBar(context),
              const SizedBox(height: AppDimensions.sm),

              // Bottom row: Assigned to + Due date
              _buildBottomRow(context),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        // Category chip
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            item.category,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),

        // Priority indicator
        _buildPriorityBadge(context),

        const Spacer(),

        // Status chip
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final color = _getPriorityColor();
    final label = _getPriorityLabel();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final color = _getStatusColor();
    final label = _getStatusLabel();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              '${item.progress}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: LinearProgressIndicator(
            value: item.progress / 100.0,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        // Assigned to
        if (item.assignedTo != null) ...[
          Icon(
            Icons.person_outline,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              item.assignedTo!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        // Due date
        if (item.dueDate != null) ...[
          const Spacer(),
          Icon(
            Icons.schedule,
            size: 14,
            color: item.isOverdue ? AppColors.error : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: item.isOverdue
                      ? AppColors.error
                      : AppColors.textSecondary,
                  fontWeight:
                      item.isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  Color _getStatusColor() {
    switch (item.status) {
      case ItemStatus.active:
        return AppColors.info;
      case ItemStatus.pending:
        return AppColors.warning;
      case ItemStatus.completed:
        return AppColors.success;
      case ItemStatus.cancelled:
        return AppColors.textDisabled;
    }
  }

  String _getStatusLabel() {
    switch (item.status) {
      case ItemStatus.active:
        return 'Active';
      case ItemStatus.pending:
        return 'Pending';
      case ItemStatus.completed:
        return 'Completed';
      case ItemStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getPriorityColor() {
    switch (item.priority) {
      case ItemPriority.low:
        return AppColors.textSecondary;
      case ItemPriority.medium:
        return AppColors.info;
      case ItemPriority.high:
        return AppColors.warning;
      case ItemPriority.urgent:
        return AppColors.error;
    }
  }

  String _getPriorityLabel() {
    switch (item.priority) {
      case ItemPriority.low:
        return 'Low';
      case ItemPriority.medium:
        return 'Medium';
      case ItemPriority.high:
        return 'High';
      case ItemPriority.urgent:
        return 'Urgent';
    }
  }

  IconData _getPriorityIcon() {
    switch (item.priority) {
      case ItemPriority.low:
        return Icons.arrow_downward;
      case ItemPriority.medium:
        return Icons.remove;
      case ItemPriority.high:
        return Icons.arrow_upward;
      case ItemPriority.urgent:
        return Icons.priority_high;
    }
  }

  Color _getProgressColor() {
    if (item.progress >= 80) return AppColors.success;
    if (item.progress >= 50) return AppColors.primary;
    if (item.progress >= 25) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDueDate() {
    if (item.dueDate == null) return '';
    final now = DateTime.now();
    final diff = item.dueDate!.difference(now);

    if (item.isOverdue) {
      final days = diff.inDays.abs();
      if (days == 0) return 'Due today';
      if (days == 1) return '1 day overdue';
      return '$days days overdue';
    }

    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    if (diff.inDays < 7) return 'Due in ${diff.inDays} days';

    return '${item.dueDate!.day}/${item.dueDate!.month}/${item.dueDate!.year}';
  }
}
