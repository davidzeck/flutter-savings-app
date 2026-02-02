import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/user.dart';
import '../dashboard/dashboard_view.dart';
import '../dashboard/dashboard_viewmodel.dart';
import '../profile/profile_view.dart';
import '../settings/settings_view.dart';

/// Main app shell with bottom navigation bar
///
/// Contains Dashboard, Profile, and Settings tabs.
/// Manages tab switching and shared state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, _) {
        final user = _buildUserFromViewModel(viewModel);

        final screens = [
          const DashboardView(),
          ProfileView(user: user),
          SettingsView(
            onLogout: () => _handleLogout(context, viewModel),
            onThemeToggle: _toggleTheme,
            isDarkMode: _isDarkMode,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: AppStrings.dashboard,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: AppStrings.profile,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: AppStrings.settings,
              ),
            ],
          ),
        );
      },
    );
  }

  User? _buildUserFromViewModel(DashboardViewModel viewModel) {
    if (viewModel.userName.isEmpty) return null;
    // The full user object is available via the repository cache
    // For the profile screen, we reconstruct from what's available
    return User(
      id: 'demo-001',
      email: 'demo@example.com',
      name: viewModel.userName,
      bio: 'Senior Operations Manager at TechCorp Global. 8+ years leading cross-functional teams in enterprise digital transformation. MBA from Stanford.',
      phone: '+1 (415) 867-5309',
      profileImage: 'https://i.pravatar.cc/300?u=sarah-mitchell',
      createdAt: DateTime.now().subtract(const Duration(days: 730)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDarkMode ? 'Dark mode enabled' : 'Light mode enabled'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    DashboardViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(AppStrings.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await viewModel.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
