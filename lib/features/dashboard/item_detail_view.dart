import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/dashboard_item.dart';

/// Full-page detail view for a dashboard item
class ItemDetailView extends StatelessWidget {
  final DashboardItem item;

  const ItemDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status + Priority badges
            Row(
              children: [
                _statusChip(context),
                const SizedBox(width: AppDimensions.sm),
                _priorityChip(context),
                const Spacer(),
                _categoryChip(context),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Title
            Text(
              item.title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Description
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Progress section
            _buildProgressSection(context),
            const SizedBox(height: AppDimensions.lg),

            // Details card
            _buildDetailsCard(context),
            const SizedBox(height: AppDimensions.md),

            // Timeline card
            _buildTimelineCard(context),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    Color color;
    switch (item.status) {
      case ItemStatus.active:
        color = AppColors.primary;
        break;
      case ItemStatus.pending:
        color = AppColors.warning;
        break;
      case ItemStatus.completed:
        color = AppColors.success;
        break;
      case ItemStatus.cancelled:
        color = AppColors.textDisabled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        item.status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _priorityChip(BuildContext context) {
    Color color;
    IconData icon;
    switch (item.priority) {
      case ItemPriority.urgent:
        color = AppColors.error;
        icon = Icons.priority_high;
        break;
      case ItemPriority.high:
        color = AppColors.warning;
        icon = Icons.arrow_upward;
        break;
      case ItemPriority.medium:
        color = AppColors.primary;
        icon = Icons.remove;
        break;
      case ItemPriority.low:
        color = AppColors.success;
        icon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            item.priority.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        item.category,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final progressColor = item.progress >= 80
        ? AppColors.success
        : item.progress >= 50
            ? AppColors.primary
            : item.progress >= 25
                ? AppColors.warning
                : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${item.progress}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              child: LinearProgressIndicator(
                value: item.progress / 100,
                backgroundColor: progressColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Divider(height: AppDimensions.lg),
            if (item.assignedTo != null)
              _detailRow(context, Icons.person_outline, 'Assigned to', item.assignedTo!),
            _detailRow(context, Icons.category_outlined, 'Category', item.category),
            _detailRow(context, Icons.flag_outlined, 'Priority', item.priority.name[0].toUpperCase() + item.priority.name.substring(1)),
            _detailRow(context, Icons.info_outline, 'Status', item.status.name[0].toUpperCase() + item.status.name.substring(1)),
            if (item.isOverdue)
              _detailRow(context, Icons.warning_amber_rounded, 'Overdue', 'Yes', valueColor: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Divider(height: AppDimensions.lg),
            _detailRow(context, Icons.calendar_today_outlined, 'Created', _formatDate(item.createdAt)),
            if (item.updatedAt != null)
              _detailRow(context, Icons.update_outlined, 'Last updated', _formatDate(item.updatedAt!)),
            if (item.dueDate != null)
              _detailRow(
                context,
                Icons.event_outlined,
                'Due date',
                _formatDate(item.dueDate!),
                valueColor: item.isOverdue ? AppColors.error : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
