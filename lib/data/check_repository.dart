import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/check.dart';

abstract class CheckRepository {
  Future<List<Check>> getAllChecks();
  Future<Check?> getCheckById(String id);
  Future<void> addCheck(Check check);
  Future<void> updateCheck(Check check);
  Future<void> deleteCheck(String id);
  Future<void> toggleCheckStatus(String id);
  Future<List<Check>> getCompletedChecks();
  Future<List<Check>> getPendingChecks();
}

class LocalCheckRepository implements CheckRepository {
  static const String _checksKey = 'checks';
  SharedPreferences? _preferences;

  Future<SharedPreferences> get preferences async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  @override
  Future<List<Check>> getAllChecks() async {
    try {
      final prefs = await preferences;
      final checksJson = prefs.getStringList(_checksKey) ?? [];

      return checksJson
          .map((checkString) => Check.fromJson(jsonDecode(checkString)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to load checks: $e');
    }
  }

  @override
  Future<Check?> getCheckById(String id) async {
    try {
      final checks = await getAllChecks();
      for (final c in checks) {
        if (c.id == id) return c;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get check by id: $e');
    }
  }

  @override
  Future<void> addCheck(Check check) async {
    try {
      final checks = await getAllChecks();
      checks.add(check);
      await _saveChecks(checks);
    } catch (e) {
      throw Exception('Failed to add check: $e');
    }
  }

  @override
  Future<void> updateCheck(Check check) async {
    try {
      final checks = await getAllChecks();
      final index = checks.indexWhere((c) => c.id == check.id);

      if (index != -1) {
        checks[index] = check;
        await _saveChecks(checks);
      } else {
        throw Exception('Check not found');
      }
    } catch (e) {
      throw Exception('Failed to update check: $e');
    }
  }

  @override
  Future<void> deleteCheck(String id) async {
    try {
      final checks = await getAllChecks();
      checks.removeWhere((check) => check.id == id);
      await _saveChecks(checks);
    } catch (e) {
      throw Exception('Failed to delete check: $e');
    }
  }

  @override
  Future<void> toggleCheckStatus(String id) async {
    try {
      final check = await getCheckById(id);
      if (check != null) {
        final updatedCheck = check.copyWith(
          isCompleted: !check.isCompleted,
          completedAt: !check.isCompleted ? DateTime.now() : null,
        );
        await updateCheck(updatedCheck);
      } else {
        throw Exception('Check not found');
      }
    } catch (e) {
      throw Exception('Failed to toggle check status: $e');
    }
  }

  @override
  Future<List<Check>> getCompletedChecks() async {
    try {
      final checks = await getAllChecks();
      return checks.where((check) => check.isCompleted).toList();
    } catch (e) {
      throw Exception('Failed to get completed checks: $e');
    }
  }

  @override
  Future<List<Check>> getPendingChecks() async {
    try {
      final checks = await getAllChecks();
      return checks.where((check) => !check.isCompleted).toList();
    } catch (e) {
      throw Exception('Failed to get pending checks: $e');
    }
  }

  Future<void> _saveChecks(List<Check> checks) async {
    try {
      final prefs = await preferences;
      final checksJson = checks
          .map((check) => jsonEncode(check.toJson()))
          .toList();
      await prefs.setStringList(_checksKey, checksJson);
    } catch (e) {
      throw Exception('Failed to save checks: $e');
    }
  }

  // Additional utility methods
  Future<int> getChecksCount() async {
    final checks = await getAllChecks();
    return checks.length;
  }

  Future<int> getCompletedChecksCount() async {
    final completedChecks = await getCompletedChecks();
    return completedChecks.length;
  }

  Future<int> getPendingChecksCount() async {
    final pendingChecks = await getPendingChecks();
    return pendingChecks.length;
  }

  Future<void> clearAllChecks() async {
    try {
      final prefs = await preferences;
      await prefs.remove(_checksKey);
    } catch (e) {
      throw Exception('Failed to clear all checks: $e');
    }
  }

  Future<List<Check>> searchChecks(String query) async {
    try {
      final checks = await getAllChecks();
      final lowercaseQuery = query.toLowerCase();

      return checks
          .where(
            (check) =>
                check.title.toLowerCase().contains(lowercaseQuery) ||
                check.description.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search checks: $e');
    }
  }
}
