// lib/services/support_service.dart
import 'package:dio/dio.dart';
import '../models/support_ticket.dart';
import '../models/support_category.dart';
import 'api_service.dart';

class SupportService {
  final ApiService _apiService;

  SupportService(this._apiService);

  Future<void> submitSupportTicket({
    required SupportCategory category,
    required String description,
    String? sourceUrl,
    String? userEmail,
    String? factCheckId,
  }) async {
    final ticket = SupportTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      description: description,
      sourceUrl: sourceUrl,
      createdAt: DateTime.now(),
      userEmail: userEmail,
      factCheckId: factCheckId,
    );

    try {
      await _apiService.post('/support/tickets', data: ticket.toJson());
    } on DioException catch (e) {
      throw Exception('Eroare la trimiterea ticket-ului: ${e.message}');
    }
  }

  Future<List<SupportTicket>> getUserTickets() async {
    try {
      final response = await _apiService.get('/support/tickets/my');
      final List<dynamic> data = response.data['tickets'] ?? [];

      return data.map((json) => SupportTicket.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Eroare la încărcarea ticket-urilor: ${e.message}');
    }
  }
}
