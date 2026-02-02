import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash/splash_view.dart';
import 'features/auth/login/login_view.dart';
import 'features/auth/login/login_viewmodel.dart';
import 'features/dashboard/dashboard_viewmodel.dart';
import 'features/home/home_shell.dart';
import 'core/widgets/connectivity_banner.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Operations',
      debugShowCheckedModeBanner: false,

      // Apply custom theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Wrap all screens with connectivity banner
      builder: (context, child) {
        return ConnectivityBanner(child: child!);
      },

      // Initial route
      initialRoute: '/',

      // Routes
      routes: {
        '/': (context) => const SplashView(),
        '/login': (context) => ChangeNotifierProvider(
              create: (_) => getIt<LoginViewModel>(),
              child: const LoginView(),
            ),
        '/dashboard': (context) => ChangeNotifierProvider(
              create: (_) => getIt<DashboardViewModel>(),
              child: const HomeShell(),
            ),
      },
    );
  }
}
