// lib/models/support_ticket.dart
import 'support_category.dart';

class SupportTicket {
  final String id;
  final SupportCategory category;
  final String description;
  final String? sourceUrl;
  final DateTime createdAt;
  final String? userEmail;
  final String? factCheckId;

  const SupportTicket({
    required this.id,
    required this.category,
    required this.description,
    this.sourceUrl,
    required this.createdAt,
    this.userEmail,
    this.factCheckId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'description': description,
      'sourceUrl': sourceUrl,
      'createdAt': createdAt.toIso8601String(),
      'userEmail': userEmail,
      'factCheckId': factCheckId,
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      category: SupportCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      description: json['description'] as String,
      sourceUrl: json['sourceUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userEmail: json['userEmail'] as String?,
      factCheckId: json['factCheckId'] as String?,
    );
  }
}
