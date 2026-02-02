import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/user.dart';

/// Profile screen showing user details and activity summary
class ProfileView extends StatelessWidget {
  final User? user;

  const ProfileView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingScreen),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.md),

            // Avatar
            _buildAvatar(context),
            const SizedBox(height: AppDimensions.md),

            // Name
            Text(
              user!.name,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.xs),

            // Email
            Text(
              user!.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Bio card
            if (user!.bio != null && user!.bio!.isNotEmpty) _buildBioCard(context),

            const SizedBox(height: AppDimensions.md),

            // Info cards
            _buildInfoSection(context),

            const SizedBox(height: AppDimensions.md),

            // Activity stats
            _buildActivityStats(context),

            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      radius: AppDimensions.avatarXLarge / 2,
      backgroundColor: AppColors.primary,
      backgroundImage:
          user!.hasProfileImage ? NetworkImage(user!.profileImage!) : null,
      child: user!.hasProfileImage
          ? null
          : Text(
              user!.initials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
    );
  }

  Widget _buildBioCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              user!.bio!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contact_mail_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: AppDimensions.lg),
            _infoRow(context, Icons.email_outlined, 'Email', user!.email),
            if (user!.phone != null)
              _infoRow(context, Icons.phone_outlined, 'Phone', user!.phone!),
            _infoRow(
              context,
              Icons.calendar_today_outlined,
              'Member since',
              _formatDate(user!.createdAt),
            ),
            _infoRow(
              context,
              Icons.update_outlined,
              'Last active',
              _formatDate(user!.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textDisabled,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'Activity Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: AppDimensions.lg),
            Row(
              children: [
                _statTile(context, '24', 'Tasks\nCompleted', AppColors.success),
                _statTile(context, '8', 'In\nProgress', AppColors.primary),
                _statTile(context, '3', 'Overdue', AppColors.error),
                _statTile(context, '92%', 'On-Time\nRate', AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
