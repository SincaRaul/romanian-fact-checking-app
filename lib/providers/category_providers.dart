import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/api_service.dart';

// Categories provider - fetches all available categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.get('/categories');

  // Convert response to List<Category>
  final List<dynamic> categoriesJson = response.data;
  return categoriesJson.map((json) => Category.fromJson(json)).toList();
});

// API service provider (assuming it exists in your current setup)
final apiServiceProvider = Provider((ref) => ApiService());
