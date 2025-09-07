// lib/features/home/widgets/hot_news_strip.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // for unawaited
import '../../../models/fact_check.dart';
import '../../../providers/fact_check_providers.dart';

class HotNewsStrip extends ConsumerWidget {
  final List<FactCheck> factChecks;
  final String? sourceScreen; // 'home' or 'explore'

  const HotNewsStrip({
    super.key, 
    required this.factChecks,
    this.sourceScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (factChecks.isEmpty) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;

    // Responsive dimensions based on screen size
    final cardHeight =
        screenSize.height * 0.22; // 10% of screen height (mai mic)
    final cardWidth = screenSize.width > 1200
        ? screenSize.width *
              0.3 // 30% pe desktop
        : screenSize.width * 0.7; // 70% pe mobile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Direct to horizontal scrolling list - no header
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04, // 4% of screen width
              vertical: screenSize.height * 0.01, // 1% of screen height
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: factChecks.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: screenSize.width * 0.03), // 3% spacing
            itemBuilder: (context, i) => _HotCard(
              item: factChecks[i],
              cardWidth: cardWidth,
              cardHeight:
                  cardHeight * 0.8, // 80% of available height for content
              sourceScreen: sourceScreen,
            ),
          ),
        ),
      ],
    );
  }

}

class _HotCard extends ConsumerWidget {
  const _HotCard({
    required this.item,
    required this.cardWidth,
    required this.cardHeight,
    this.sourceScreen,
  });

  final FactCheck item;
  final double cardWidth;
  final double cardHeight;
  final String? sourceScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: cardWidth,
        height: cardHeight,
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Fire-and-forget analytics tracking
            unawaited(ref.read(analyticsServiceProvider).trackOpen(item.id));
            
            // Include source information for proper back navigation
            final source = sourceScreen ?? 'home';
            context.push('/details/${item.id}?source=$source');
          },
          child: Padding(
            padding: EdgeInsets.all(
              cardHeight * 0.1,
            ), // 10% of card height as padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hot indicator only (no verdict)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardWidth * 0.015, // mai mic padding
                        vertical: cardHeight * 0.01, // mai mic padding
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥',
                            style: TextStyle(fontSize: cardHeight * 0.12), // 12% din cardHeight
                          ),
                          SizedBox(width: cardWidth * 0.005),
                          Text(
                            'HOT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: cardHeight * 0.08, // 8% din cardHeight
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Verdict removed - mai mult spațiu pentru title
                  ],
                ),
                SizedBox(height: cardHeight * 0.06), // mai mult spacing pentru title
                // Title - mai mult spațiu, font mai mic
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.1, // line height mai mic
                      fontSize: cardHeight * 0.12, // 12% din cardHeight
                    ),
                    maxLines: 3, // mai multe linii pentru tot titlul
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: cardHeight * 0.03), // mai puțin spacing
                // Category and time - mai mici
                Row(
                  children: [
                    if (item.category != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: cardWidth * 0.02,
                          vertical: cardHeight * 0.008, // foarte mic padding
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getCategoryLabel(item.category!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: cardHeight * 0.08, // 8% din cardHeight
                          ),
                        ),
                      ),
                      SizedBox(width: cardWidth * 0.015),
                    ],
                    Expanded(
                      child: Text(
                        _formatTimeAgo(item.publishedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: cardHeight * 0.08, // 8% din cardHeight
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getCategoryLabel(String category) {
  // TODO: Move this to categories provider for consistency
  switch (category) {
    case 'football':
      return 'Fotbal';
    case 'politics_internal':
      return 'Politică';
    case 'politics_external':
      return 'Extern';
    case 'health':
      return 'Sănătate';
    case 'technology':
      return 'Tech';
    case 'environment':
      return 'Mediu';
    case 'economy':
      return 'Economie';
    case 'bills':
      return 'Facturi';
    default:
      return 'Altele';
  }
}

String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final delta = now.difference(dateTime);

  // Safety: handle negative differences (clock skew)
  final difference = delta.isNegative ? Duration.zero : delta;

  if (difference.inDays > 0) {
    return '${difference.inDays}z';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else {
    return '${difference.inMinutes}m';
  }
}
