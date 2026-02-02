import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

/// Settings screen with theme toggle, app info, and preferences
class SettingsView extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SettingsView({
    super.key,
    required this.onLogout,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        children: [
          // Appearance section
          _sectionHeader(context, 'Appearance'),
          _settingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: AppStrings.darkMode,
            subtitle: isDarkMode ? 'On' : 'Off',
            trailing: Switch.adaptive(
              value: isDarkMode,
              onChanged: (_) => onThemeToggle(),
              activeColor: AppColors.primary,
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.language_outlined,
            title: AppStrings.language,
            subtitle: 'English (US)',
            onTap: () => _showSnackBar(context, 'Language settings coming soon'),
          ),

          const Divider(height: AppDimensions.lg),

          // Notifications section
          _sectionHeader(context, 'Notifications'),
          _settingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Enabled',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (_) => _showSnackBar(context, 'Notification settings coming soon'),
              activeColor: AppColors.primary,
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Weekly digest',
            onTap: () => _showSnackBar(context, 'Email notification settings coming soon'),
          ),

          const Divider(height: AppDimensions.lg),

          // Data & Storage section
          _sectionHeader(context, 'Data & Storage'),
          _settingsTile(
            context,
            icon: Icons.cached_outlined,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _showClearCacheDialog(context),
          ),
          _settingsTile(
            context,
            icon: Icons.cloud_sync_outlined,
            title: 'Auto-Sync',
            subtitle: 'Sync data in background',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (_) => _showSnackBar(context, 'Auto-sync settings coming soon'),
              activeColor: AppColors.primary,
            ),
          ),

          const Divider(height: AppDimensions.lg),

          // About section
          _sectionHeader(context, 'About'),
          _settingsTile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.about,
            subtitle: '${AppStrings.appName} v${AppStrings.appVersion}',
            onTap: () => _showAboutDialog(context),
          ),
          _settingsTile(
            context,
            icon: Icons.description_outlined,
            title: AppStrings.privacyPolicy,
            onTap: () => _showSnackBar(context, 'Privacy policy coming soon'),
          ),
          _settingsTile(
            context,
            icon: Icons.gavel_outlined,
            title: AppStrings.termsOfService,
            onTap: () => _showSnackBar(context, 'Terms of service coming soon'),
          ),

          const Divider(height: AppDimensions.lg),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingScreen,
              vertical: AppDimensions.md,
            ),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),

          // Build info
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingScreen),
            child: Text(
              'Build: 1.0.0+1 (Flutter)\nEnvironment: Demo',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textDisabled,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingScreen,
        AppDimensions.sm,
        AppDimensions.paddingScreen,
        AppDimensions.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textDisabled) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingScreen,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all locally cached data. You will need an internet connection to reload data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Icon(
                Icons.business_center,
                color: AppColors.textOnPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            const Text(AppStrings.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppStrings.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'An enterprise-grade operations management platform built with Flutter. Features MVVM architecture, offline-first data strategy, and Material Design 3.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Built with Flutter & Dart',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textDisabled,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
}
