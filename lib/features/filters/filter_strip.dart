// lib/features/filters/filter_strip.dart
import 'package:flutter/material.dart';

class FilterStrip extends StatelessWidget {
  const FilterStrip({
    super.key,
    required this.categories,
    required this.selectedKey,
    required this.onCategory,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final List<Map<String, String>> categories;
  final String? selectedKey;
  final ValueChanged<String?> onCategory;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type filter dropdown with section header
        Row(
          children: [
            Text(
              'Ultimele verificări',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: selectedType,
              underline: const SizedBox.shrink(),
              icon: Icon(Icons.filter_alt, color: colorScheme.onSurfaceVariant),
              items: const [
                DropdownMenuItem(value: 'toate', child: Text('Toate')),
                DropdownMenuItem(value: 'automate', child: Text('Automate')),
                DropdownMenuItem(value: 'manuale', child: Text('Manuale')),
              ],
              onChanged: (value) => value != null ? onTypeChanged(value) : null,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              dropdownColor: colorScheme.surface,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Categories chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              // "Toate" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Toate'),
                  selected: selectedKey == null,
                  onSelected: (_) => onCategory(null),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: selectedKey == null
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selectedKey == null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),

              // Category chips
              ...categories.map((category) {
                final key = category['key']!;
                final label = category['label']!;
                final isSelected = selectedKey == key;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => onCategory(key),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
