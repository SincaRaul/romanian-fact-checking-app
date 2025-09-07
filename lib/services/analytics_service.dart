// lib/services/analytics_service.dart
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class AnalyticsService {
  final Dio _dio;
  static const String _anonIdKey = 'anon_id';
  static const String _lastOpenKey = 'last_open_';
  static const Duration _openCooldown = Duration(seconds: 30);

  AnalyticsService(this._dio);

  /// Get or create anonymous user ID for tracking
  Future<String> getAnonId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_anonIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_anonIdKey, id);
    }
    return id;
  }

  /// Track when user opens a fact-check details page
  Future<void> trackOpen(String factCheckId) async {
    // Prevent spam - only track once per 30 seconds per fact-check
    final prefs = await SharedPreferences.getInstance();
    final lastOpenKey = '$_lastOpenKey$factCheckId';
    final lastOpen = prefs.getInt(lastOpenKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastOpen < _openCooldown.inMilliseconds) {
      return; // Too soon, skip tracking
    }

    try {
      final uid = await getAnonId();
      await _dio.post(
        '/events',
        data: {
          'type': 'open',
          'fact_check_id': factCheckId,
          'uid': uid,
          'ts': DateTime.now().toUtc().toIso8601String(),
        },
      );

      // Record this tracking event to prevent spam
      await prefs.setInt(lastOpenKey, now);
    } catch (e) {
      // Silently ignore analytics errors - don't affect user experience
      print('Analytics error: $e');
    }
  }

  /// Track meaningful engagement (user stayed >10 seconds or scrolled significantly)
  Future<void> trackEngagement(
    String factCheckId,
    String engagementType,
  ) async {
    try {
      final uid = await getAnonId();
      await _dio.post(
        '/events',
        data: {
          'type': engagementType, // 'read_complete', 'share', 'bookmark'
          'fact_check_id': factCheckId,
          'uid': uid,
          'ts': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Track search queries to understand user intent
  Future<void> trackSearch(String query, int resultCount) async {
    try {
      final uid = await getAnonId();
      await _dio.post(
        '/events',
        data: {
          'type': 'search',
          'query': query.toLowerCase().trim(),
          'result_count': resultCount,
          'uid': uid,
          'ts': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }
}
