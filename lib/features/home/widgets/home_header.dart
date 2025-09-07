// lib/features/home/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/fact_check_providers.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key, this.onSearchChanged});

  final ValueChanged<String>? onSearchChanged;

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Brand header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fact_check, size: 32, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'CheckIT',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Caută verificări, teme, oameni…',
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              widget.onSearchChanged?.call(value);

              // Track search after user stops typing (debounced)
              if (value.trim().isNotEmpty && value.trim().length >= 3) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text.trim() == value.trim()) {
                    final analytics = ref.read(analyticsServiceProvider);
                    analytics.trackSearch(
                      value.trim(),
                      0,
                    ); // We'll update count later
                  }
                });
              }
            },
            textInputAction: TextInputAction.search,
          ),
        ],
      ),
    );
  }
}
