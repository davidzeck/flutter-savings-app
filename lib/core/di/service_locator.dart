import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core Services
import '../utils/network_info.dart';
import '../../data/services/api/api_service.dart';
import '../../data/services/storage/local_storage_service.dart';

// Repositories
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/dashboard_repository.dart';

// ViewModels
import '../../features/auth/login/login_viewmodel.dart';
import '../../features/dashboard/dashboard_viewmodel.dart';

/// Service locator for dependency injection
///
/// Uses GetIt for managing dependencies throughout the app.
/// All dependencies should be registered here.
final getIt = GetIt.instance;

/// Initialize all dependencies
///
/// This function should be called in main() before runApp()
/// to ensure all dependencies are ready before the app starts.
Future<void> setupServiceLocator() async {
  // ============================================================================
  // EXTERNAL DEPENDENCIES
  // ============================================================================

  // SharedPreferences - Register as singleton (async initialization)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // FlutterSecureStorage - Register as singleton
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );

  // Dio - HTTP client
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    // Dio configuration will be done in the API service
    return dio;
  });

  // Connectivity - Network status checker
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // ============================================================================
  // CORE SERVICES
  // ============================================================================

  // Network Info Service
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(getIt<Connectivity>()),
  );

  // API Service
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<Dio>()),
  );

  // Local Storage Service
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(
      getIt<SharedPreferences>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  // ============================================================================
  // REPOSITORIES
  // ============================================================================

  // User Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(
      getIt<ApiService>(),
      getIt<LocalStorageService>(),
      getIt<NetworkInfo>(),
    ),
  );

  // Dashboard Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(
      getIt<ApiService>(),
      getIt<LocalStorageService>(),
      getIt<NetworkInfo>(),
    ),
  );

  // ============================================================================
  // VIEW MODELS
  // ============================================================================

  // Login ViewModel - Factory (new instance each time)
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<UserRepository>()),
  );

  // Dashboard ViewModel - Factory (new instance each time)
  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getIt<DashboardRepository>(),
      getIt<UserRepository>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Check if a dependency is registered
bool isRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}
