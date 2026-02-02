import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/user_repository.dart';

/// Splash screen view
///
/// Displays app logo and checks authentication status
/// Routes to Login or Dashboard based on auth state
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Check auth and navigate
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    try {
      // Check if user is authenticated
      final userRepository = getIt<UserRepository>();
      final isAuthenticated = await userRepository.isAuthenticated();

      if (!mounted) return;

      if (isAuthenticated) {
        // Try to get current user
        final user = await userRepository.getCurrentUser();

        if (!mounted) return;

        if (user != null) {
          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // Token exists but couldn't fetch user, go to login
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // Not authenticated, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error during auth check: $e');
      if (!mounted) return;

      // On error, go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Hero(
                tag: 'app-logo',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.business_center,
                    size: 70,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.lg),

              // App Name
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppDimensions.xs),

              // Tagline
              Text(
                'Enterprise Operations',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
              ),

              const SizedBox(height: AppDimensions.xl),

              // Loading indicator
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
