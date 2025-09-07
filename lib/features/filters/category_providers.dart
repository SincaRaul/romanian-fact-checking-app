// lib/features/filters/category_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pentru categorii disponibile
final categoriesProvider = StateProvider<List<Map<String, String>>>((ref) {
  return [
    {'key': 'politics', 'label': 'Politică'},
    {'key': 'health', 'label': 'Sănătate'},
    {'key': 'sports', 'label': 'Sport'},
    {'key': 'international', 'label': 'Internațional'},
    {'key': 'economy', 'label': 'Economie'},
    {'key': 'technology', 'label': 'Tehnologie'},
    {'key': 'environment', 'label': 'Mediu'},
    {'key': 'social', 'label': 'Social'},
  ];
});

// Provider pentru categoria selectată
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider pentru tipul de sortare
final sortTypeProvider = StateProvider<String>((ref) => 'new');

// Provider pentru termenul de căutare
final searchTermProvider = StateProvider<String>((ref) => '');
