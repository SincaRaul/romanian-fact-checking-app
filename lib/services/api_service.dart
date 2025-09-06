import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Auto-detect environment
  static String get baseUrl {
    if (kIsWeb) {
      // In production, this will be your Railway URL
      // For now, we'll use localhost for development
      const prodUrl = String.fromEnvironment('API_URL', 
          defaultValue: 'http://localhost:8000');
      return prodUrl;
    }
    return 'http://localhost:8000';
  }

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {'Content-Type': 'application/json'},
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
}
