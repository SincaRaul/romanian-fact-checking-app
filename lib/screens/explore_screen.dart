import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/fact_check.dart';
import '../providers/fact_check_providers.dart';
import '../features/home/home_providers.dart';
import '../features/filters/category_providers.dart';
import '../features/filters/filter_strip.dart';
import '../widgets/verdict_badge.dart';
import '../features/home/widgets/hot_news_strip.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedCategory;
  String _selectedType = 'toate'; // toate, automate, manuale
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Buttons at the top
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: const [
                      Tab(text: 'Toate'),
                      Tab(text: 'Analize'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter Section
          _buildSearchAndFilters(),

          // Hot News Section
          Consumer(
            builder: (context, ref, child) {
              final hotChecks = ref.watch(hotFactChecksProvider);
              return hotChecks.when(
                data: (checks) => checks.isNotEmpty
                    ? HotNewsStrip(
                        factChecks: checks.take(5).toList(),
                        sourceScreen: 'explore',
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAllFactChecks(), _buildAnalyticsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final categories = ref.watch(categoriesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Caută fact-check-uri...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),

          // Categories Filter Strip with "Ultimele verificări" header
          FilterStrip(
            categories: categories,
            selectedKey: _selectedCategory,
            onCategory: (key) {
              setState(() {
                _selectedCategory = key;
              });
            },
            selectedType: _selectedType,
            onTypeChanged: (newType) {
              setState(() {
                _selectedType = newType;
              });
            },
          ),

          // Clear Filters Button (only when needed)
          if (_selectedCategory != null || _selectedType != 'toate')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildFilterChip(
                  label: 'Șterge filtre',
                  icon: Icons.clear,
                  isSelected: false,
                  onTap: () => setState(() {
                    _selectedCategory = null;
                    _selectedType = 'toate';
                  }),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllFactChecks() {
    final asyncFactChecks = ref.watch(latestFactChecksProvider);

    return asyncFactChecks.when(
      data: (factChecks) {
        var filteredChecks = factChecks.where((check) {
          // Search filter
          if (_searchQuery.isNotEmpty) {
            if (!check.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            )) {
              return false;
            }
          }

          // Category filter
          if (_selectedCategory != null &&
              check.category != _selectedCategory) {
            return false;
          }

          // Type filter (automate/manuale)
          if (_selectedType == 'Automate' && !check.autoGenerated) {
            return false;
          }
          if (_selectedType == 'Editoriale' && check.autoGenerated) {
            return false;
          }

          return true;
        }).toList();

        if (filteredChecks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(latestFactChecksProvider);
            ref.invalidate(homeStatisticsProvider);
            ref.invalidate(statsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredChecks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFactCheckCard(filteredChecks[index]),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error),
    );
  }

  Widget _buildAnalyticsTab() {
    final stats = ref.watch(statsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(statsProvider);
        ref.invalidate(homeStatisticsProvider);
        ref.invalidate(latestFactChecksProvider);
      },
      child: stats.when(
        data: (statsData) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Verificări Totale',
                    statsData['newCount'].toString(),
                    Icons.fact_check,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Generate Automat',
                    '${statsData['autoGeneratedPct']}%',
                    Icons.smart_toy,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Verificări Editoriale',
                    '${statsData['editorialPct']}%',
                    Icons.verified,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Acuratețe Est.',
                    '${((statsData['editorialPct'] + statsData['autoGeneratedPct'] / 2) * 0.85).round()}%',
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Insights
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informații Rapide',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.trending_up, color: Colors.orange),
                      title: Text('Cel mai verificat subiect'),
                      subtitle: Text('Politică și Guvernare'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: Icon(Icons.schedule, color: Colors.purple),
                      title: Text('Timp mediu de verificare'),
                      subtitle: Text('2-4 ore'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: Icon(Icons.analytics, color: Colors.blue),
                      title: Text('Precisie medie'),
                      subtitle: Text(
                        '${((statsData['editorialPct'] + statsData['autoGeneratedPct'] / 2) * 0.9).round()}%',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Eroare la încărcarea statisticilor'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(statsProvider),
                  child: Text('Încearcă din nou'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactCheckCard(
    FactCheck factCheck, {
    bool showPopularityBadge = false,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navighez cu query parameter pentru a ști de unde vin
          context.go('/details/${factCheck.id}?from=explore');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Verdict Badge
                  VerdictBadge(factCheck: factCheck),
                  const Spacer(),

                  // Popularity Badge (doar pentru recente)
                  if (showPopularityBadge) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Recent',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Badge pentru tipul de verificare
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: factCheck.autoGenerated
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          factCheck.autoGenerated
                              ? Icons.smart_toy
                              : Icons.verified,
                          size: 12,
                          color: factCheck.autoGenerated
                              ? Colors.blue.shade700
                              : Colors.green.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          factCheck.autoGenerated ? 'AI' : 'Manual',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: factCheck.autoGenerated
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                factCheck.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Metadata Row
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(factCheck.publishedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (factCheck.autoGenerated) ...[
                    Icon(
                      Icons.smart_toy,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verificare automată',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nu am găsit rezultate',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Încearcă să modifici filtrele sau termenii de căutare',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _searchQuery = '';
              _selectedCategory = null;
              _selectedType = 'toate';
            }),
            child: const Text('Șterge toate filtrele'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Eroare la încărcarea datelor',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(latestFactChecksProvider);
            },
            child: const Text('Încearcă din nou'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} zile';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
