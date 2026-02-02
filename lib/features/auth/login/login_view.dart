import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import 'login_viewmodel.dart';

/// Login screen view
///
/// Displays login form with email and password fields
/// Handles user authentication flow
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => context.read<LoginViewModel>(),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, _) {
              // Navigate to dashboard on successful login
              if (viewModel.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                });
              }

              return _buildBody(context, viewModel);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LoginViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingScreen),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimensions.xxxl),

            // Logo/Title
            _buildHeader(),

            const SizedBox(height: AppDimensions.xxl),

            // Error message (if any)
            if (viewModel.errorMessage != null)
              _buildErrorMessage(viewModel.errorMessage!),

            const SizedBox(height: AppDimensions.md),

            // Email field
            _buildEmailField(viewModel),

            const SizedBox(height: AppDimensions.md),

            // Password field
            _buildPasswordField(viewModel),

            const SizedBox(height: AppDimensions.lg),

            // Login button
            _buildLoginButton(viewModel),

            const SizedBox(height: AppDimensions.md),

            // Forgot password link
            _buildForgotPassword(),

            const SizedBox(height: AppDimensions.xl),

            // Demo credentials hint
            _buildDemoHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: const Icon(
            Icons.business_center,
            size: AppDimensions.iconXLarge,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.md),

        // Title
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: AppDimensions.xs),

        // Subtitle
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.error,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppDimensions.iconMedium,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(LoginViewModel viewModel) {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !viewModel.isLoading,
      decoration: InputDecoration(
        labelText: AppStrings.email,
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: viewModel.emailError,
      ),
      onChanged: viewModel.updateEmail,
    );
  }

  Widget _buildPasswordField(LoginViewModel viewModel) {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.done,
      enabled: !viewModel.isLoading,
      decoration: InputDecoration(
        labelText: AppStrings.password,
        prefixIcon: const Icon(Icons.lock_outlined),
        errorText: viewModel.passwordError,
      ),
      onChanged: viewModel.updatePassword,
      onSubmitted: (_) {
        if (viewModel.isFormValid && !viewModel.isLoading) {
          viewModel.login();
        }
      },
    );
  }

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.isLoading || !viewModel.isFormValid
          ? null
          : viewModel.login,
      child: viewModel.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            )
          : const Text(AppStrings.login),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        // TODO: Navigate to forgot password screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forgot password feature coming soon'),
          ),
        );
      },
      child: const Text(AppStrings.forgotPassword),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Demo Credentials',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Email: demo@example.com\nPassword: password123',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}
