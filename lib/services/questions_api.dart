import 'package:dio/dio.dart';
import '../services/api_service.dart';

class QuestionsApi {
  final ApiService _apiService;

  QuestionsApi(this._apiService);

  /// Create a new question
  Future<Map<String, dynamic>> create(String title, {String? body}) async {
    try {
      final response = await _apiService.dio.post(
        '/questions',
        data: {'title': title, 'body': body},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to create question: ${e.message}');
    }
  }

  /// Get list of questions
  Future<List<Map<String, dynamic>>> list({
    int limit = 50,
    String? statusFilter,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/questions',
        queryParameters: {
          'limit': limit,
          if (statusFilter != null) 'status_filter': statusFilter,
        },
      );
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Failed to get questions: ${e.message}');
    }
  }

  /// Vote for a question
  Future<Map<String, dynamic>> vote(
    String questionId, {
    String? deviceId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/questions/$questionId/vote',
        options: Options(
          headers: {if (deviceId != null) 'X-Device-Id': deviceId},
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to vote: ${e.message}');
    }
  }
}
