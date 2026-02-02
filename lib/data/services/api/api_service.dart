import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// API Service for handling all HTTP requests
///
/// This service wraps Dio and provides:
/// - Centralized API configuration
/// - Error handling and mapping
/// - Request/response interceptors
/// - Type-safe API calls
class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _configureDio();
  }

  /// Configure Dio with base options and interceptors
  void _configureDio() {
    // Base options
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(seconds: ApiConstants.sendTimeout),
      headers: {
        ApiConstants.contentType: ApiConstants.applicationJson,
        ApiConstants.accept: ApiConstants.applicationJson,
      },
      validateStatus: (status) {
        // Accept all status codes and handle errors manually
        return status != null && status < 500;
      },
    );

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  /// Logging interceptor for debugging
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 REQUEST[${options.method}] => ${options.uri}');
        print('Headers: ${options.headers}');
        if (options.data != null) {
          print('Data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
        print('Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
        print('Message: ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Auth interceptor to add token to requests
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from secure storage
        // This will be implemented when we create the storage service
        // final token = await _getAuthToken();
        // if (token != null && token.isNotEmpty) {
        //   options.headers[ApiConstants.authorization] =
        //       '${ApiConstants.bearer} $token';
        // }
        handler.next(options);
      },
    );
  }

  /// Error interceptor to handle and transform errors
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleError(error);
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: exception,
            type: error.type,
          ),
        );
      },
    );
  }

  // ============================================================================
  // AUTH ENDPOINTS
  // ============================================================================

  /// Login user with email and password
  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout current user
  Future<Response> logout() async {
    try {
      return await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user
  Future<Response> getCurrentUser() async {
    try {
      return await _dio.get(ApiConstants.currentUser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  Future<Response> updateProfile({
    required String name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      return await _dio.put(
        ApiConstants.updateProfile,
        data: {
          'name': name,
          if (bio != null) 'bio': bio,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // DASHBOARD ENDPOINTS
  // ============================================================================

  /// Get dashboard items with pagination
  Future<Response> getDashboardItems({
    int page = ApiConstants.defaultPage,
    int limit = ApiConstants.defaultPageSize,
  }) async {
    try {
      return await _dio.get(
        ApiConstants.dashboardItems,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh dashboard data
  Future<Response> refreshDashboard() async {
    try {
      return await _dio.get(ApiConstants.dashboardRefresh);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get dashboard item by ID
  Future<Response> getDashboardItem(String id) async {
    try {
      return await _dio.get(ApiConstants.getDashboardItem(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Handle and transform Dio errors to app exceptions
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response!);

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badCertificate:
        return const ServerException('SSL Certificate error');

      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkException();
        }
        return UnknownException(
          'An unexpected error occurred',
          error.message,
        );
    }
  }

  /// Handle response errors based on status code
  AppException _handleResponseError(Response response) {
    final statusCode = response.statusCode ?? 0;
    final message = _extractErrorMessage(response);

    switch (statusCode) {
      case 400:
        return ValidationException(message);

      case 401:
        return UnauthorizedException(message);

      case 403:
        return ForbiddenException(message);

      case 404:
        return NotFoundException(message);

      case 409:
        return ConflictException(message);

      case 422:
        final errors = _extractValidationErrors(response);
        return ValidationException(message, errors);

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message, statusCode);

      default:
        return ServerException(
          message.isNotEmpty ? message : 'Server error occurred',
          statusCode,
        );
    }
  }

  /// Extract error message from response
  String _extractErrorMessage(Response response) {
    try {
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return data['message'] as String? ??
            data['error'] as String? ??
            'An error occurred';
      }
      return 'An error occurred';
    } catch (e) {
      return 'An error occurred';
    }
  }

  /// Extract validation errors from response
  Map<String, String>? _extractValidationErrors(Response response) {
    try {
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          return errors.map(
            (key, value) => MapEntry(
              key,
              value is List ? value.first.toString() : value.toString(),
            ),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Cancel all pending requests
  void cancelRequests() {
    _dio.close(force: true);
  }
}
