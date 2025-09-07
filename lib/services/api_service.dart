import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Auto-detect environment
  static String get baseUrl {
    if (kIsWeb) {
      // In production, this will be your Railway URL
      // For now, we'll use localhost for development
      const prodUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:8000',
      );
      return prodUrl;
    }
    return 'http://localhost:8000';
  }

  late final Dio _dio;
  static const _secureStorage = FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(
          seconds: 120,
        ), // Increased for Gemini 2.5 Pro
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add admin auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add admin token to requests to /admin endpoints
          if (options.path.startsWith('/admin')) {
            final token = await _secureStorage.read(key: 'admin_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[API] $o'),
      ),
    );
  }

  Dio get dio => _dio;

  // GET request method
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // POST request method
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // POST request method with extended timeout for AI operations
  Future<Response> postWithExtendedTimeout(String path, {dynamic data}) {
    return _dio.post(
      path,
      data: data,
      options: Options(
        receiveTimeout: const Duration(
          seconds: 180,
        ), // 3 minutes for AI operations
        sendTimeout: const Duration(seconds: 60),
      ),
    );
  }

  // Create a new fact-check (admin endpoint)
  Future<Response> createAdminFactCheck(Map<String, dynamic> factCheckData) {
    return post('/admin/fact-checks', data: factCheckData);
  }

  // Legacy method for backward compatibility
  static Future<Response> createFactCheck(Map<String, dynamic> factCheckData) {
    final apiService = ApiService();
    return apiService.post('/fact-checks', data: factCheckData);
  }
}
