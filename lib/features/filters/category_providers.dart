// lib/features/filters/category_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pentru categorii disponibile
final categoriesProvider = StateProvider<List<Map<String, String>>>((ref) {
  return [
    {'key': 'football', 'label': 'Fotbal'},
    {'key': 'politics_internal', 'label': 'Politică Internă'},
    {'key': 'politics_external', 'label': 'Politică Externă'},
    {'key': 'health', 'label': 'Sănătate'},
    {'key': 'technology', 'label': 'Tehnologie'},
    {'key': 'environment', 'label': 'Mediu'},
    {'key': 'economy', 'label': 'Economie'},
    {'key': 'bills', 'label': 'Facturi și Utilități'},
    {'key': 'other', 'label': 'Altele'},
  ];
});

// Provider pentru categoria selectată
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider pentru tipul de sortare
final sortTypeProvider = StateProvider<String>((ref) => 'new');

// Provider pentru termenul de căutare
final searchTermProvider = StateProvider<String>((ref) => '');
