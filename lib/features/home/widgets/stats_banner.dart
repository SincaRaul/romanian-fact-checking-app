// lib/features/home/widgets/stats_banner.dart
import 'package:flutter/material.dart';
import '../timeframe.dart';

class StatsBanner extends StatelessWidget {
  const StatsBanner({
    super.key,
    required this.newCount,
    required this.truePct, // 0..100
    required this.falsePct, // 0..100
    required this.timeframe,
    required this.onTimeframeChanged,
    this.onViewAll,
  });

  final int newCount;
  final int truePct;
  final int falsePct;
  final Timeframe timeframe;
  final ValueChanged<Timeframe> onTimeframeChanged;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row titlu + interval selector
            Row(
              children: [
                Icon(Icons.verified, color: colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Știri verificate',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                _buildTimeframeSelector(context),
              ],
            ),
            const SizedBox(height: 16),

            // Main count
            Text(
              '$newCount verificări noi',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),

            // KPI metrics
            _buildKPI(
              context,
              'Adevărate',
              '$truePct%',
              value: truePct / 100,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildKPI(
              context,
              'False',
              '$falsePct%',
              value: falsePct / 100,
              color: Colors.red,
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                TextButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Vezi toate'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Metodologie',
                  onPressed: () => _showMethodologyDialog(context),
                  icon: Icon(Icons.info_outline, color: colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SegmentedButton<Timeframe>(
      segments: const [
        ButtonSegment(value: Timeframe.today, label: Text('Azi')),
        ButtonSegment(value: Timeframe.week, label: Text('7z')),
        ButtonSegment(value: Timeframe.month, label: Text('30z')),
      ],
      selected: {timeframe},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onTimeframeChanged(selection.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        selectedBackgroundColor: colorScheme.primary,
        selectedForegroundColor: colorScheme.onPrimary,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildKPI(
    BuildContext context,
    String label,
    String valueText, {
    required double value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: colorScheme.surface.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  void _showMethodologyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cum calculăm aceste valori'),
        content: const Text(
          'Acuratețea și procentele sunt agregate pe intervalul selectat. '
          '„Adevărate" include și „Parțial adevărat", iar „False" include '
          '„Trunchiat/Mix" și alte categorii similare.\n\n'
          'Datele sunt actualizate în timp real pe măsură ce se adaugă '
          'noi verificări în sistem.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Înțeles'),
          ),
        ],
      ),
    );
  }
}
