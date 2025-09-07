import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/fact_check.dart';
import '../providers/fact_check_providers.dart';
import '../utils/verdict_extensions.dart';

class FactCheckDetailsScreen extends ConsumerStatefulWidget {
  final String factCheckId;
  final String? sourceScreen;

  const FactCheckDetailsScreen({
    super.key, 
    required this.factCheckId,
    this.sourceScreen,
  });

  @override
  ConsumerState<FactCheckDetailsScreen> createState() =>
      _FactCheckDetailsScreenState();
}

class _FactCheckDetailsScreenState
    extends ConsumerState<FactCheckDetailsScreen> {
  bool _hasTrackedOpen = false;
  DateTime? _entryTime;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
  }

  @override
  void dispose() {
    // Track engagement time if user stayed >10 seconds
    if (_entryTime != null) {
      final timeSpent = DateTime.now().difference(_entryTime!);
      if (timeSpent.inSeconds > 10) {
        final analytics = ref.read(analyticsServiceProvider);
        analytics.trackEngagement(widget.factCheckId, 'read_complete');
      }
    }
    super.dispose();
  }

  void _trackOpen() {
    if (!_hasTrackedOpen) {
      _hasTrackedOpen = true;
      final analytics = ref.read(analyticsServiceProvider);
      analytics.trackOpen(widget.factCheckId);
    }
  }

  Future<void> _shareFactCheck(FactCheck factCheck) async {
    // Track share action
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackEngagement(factCheck.id, 'share');

    final verdict = factCheck.verdict.displayName;
    final confidence = factCheck.confidence;

    String shareText =
        '''
📋 Fact-Check: ${factCheck.title}

🔍 Verdict: $verdict ($confidence% încredere)

📝 Rezumat:
${factCheck.summary ?? 'Nu este disponibil un rezumat.'}

📊 Categorie: ${factCheck.category ?? 'Necategorisit'}
''';

    final sources = factCheck.sources;
    if (sources != null && sources.isNotEmpty) {
      shareText += '\n🔗 Surse verificate:\n';
      for (int i = 0; i < sources.length && i < 3; i++) {
        final source = sources[i];
        final sourceName = source.split(' - ').first;
        shareText += '• $sourceName\n';
      }

      if (sources.length > 3) {
        shareText += '• ... și alte ${sources.length - 3} surse verificate\n';
      }
    }

    shareText += '\n📱 Verificare independentă - FactCheck România';

    // TODO: When deployed, add link to fact-check:
    // shareText += '\n\n🔗 Vezi detalii complete: https://factcheck.ro/check/${factCheck.id}';

    try {
      await Share.share(shareText, subject: 'Fact-Check: ${factCheck.title}');
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final factCheckAsync = ref.watch(factCheckByIdProvider(widget.factCheckId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii Fact-Check'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Mă întorc la pagina de unde am venit
            final source = widget.sourceScreen ?? 'home';
            switch (source) {
              case 'explore':
                context.go('/explore');
                break;
              case 'home':
              default:
                context.go('/home');
                break;
            }
          },
        ),
      ),
      body: factCheckAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Eroare la încărcarea datelor',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Înapoi la Home'),
              ),
            ],
          ),
        ),
        data: (factCheck) {
          // Track the open when data loads
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _trackOpen();
          });

          if (factCheck == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Fact-check-ul nu a fost găsit',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Înapoi la Home'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header cu verdict și încredere
                _buildVerdictHeader(context, factCheck),
                const SizedBox(height: 24),

                // Titlul principale
                _buildTitle(context, factCheck),
                const SizedBox(height: 16),

                // Badge-uri pentru auto-generated, etc.
                _buildBadges(context, factCheck),
                const SizedBox(height: 24),

                // Explicația detaliată (când va fi implementată în backend)
                _buildExplanation(context, factCheck),
                const SizedBox(height: 24),

                // Sources section (if available)
                if (factCheck.sources != null && factCheck.sources!.isNotEmpty)
                  _buildSources(context, factCheck),
                if (factCheck.sources != null && factCheck.sources!.isNotEmpty)
                  const SizedBox(height: 24),

                // Metadata
                _buildMetadata(context, factCheck),
                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(context, factCheck),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerdictHeader(BuildContext context, FactCheck factCheck) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: factCheck.verdict.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: factCheck.verdict.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: factCheck.verdict.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              factCheck.verdict.iconData,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verdict: ${factCheck.verdict.displayName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: factCheck.verdict.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      factCheck.autoGenerated
                          ? Icons.smart_toy
                          : Icons.verified,
                      size: 16,
                      color: factCheck.verdict.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      factCheck.autoGenerated
                          ? 'Generat AI'
                          : 'Verificat manual',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: factCheck.verdict.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, FactCheck factCheck) {
    return Text(
      factCheck.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    );
  }

  Widget _buildBadges(BuildContext context, FactCheck factCheck) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Badge pentru tipul de verificare
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: factCheck.autoGenerated
                ? Colors.blue.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: factCheck.autoGenerated
                  ? Colors.blue.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                factCheck.autoGenerated ? Icons.smart_toy : Icons.verified,
                size: 16,
                color: factCheck.autoGenerated
                    ? Colors.blue.shade700
                    : Colors.green.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                factCheck.autoGenerated ? 'Generat cu AI' : 'Verificat manual',
                style: TextStyle(
                  color: factCheck.autoGenerated
                      ? Colors.blue.shade700
                      : Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Badge pentru status complet
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.purple.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Complet verificat',
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation(BuildContext context, FactCheck factCheck) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explicație detaliată',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: colorScheme.surfaceContainerHigh,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  factCheck.summary ??
                      'Această verificare se bazează pe surse oficiale și cercetări documentate.',
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (factCheck.summary == null) ...[
                  const SizedBox(height: 16),
                  SelectableText(
                    factCheck.title,
                    textAlign: TextAlign.justify,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: factCheck.autoGenerated
                        ? colorScheme.primaryContainer
                        : colorScheme.tertiaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            factCheck.autoGenerated
                                ? Icons.smart_toy
                                : Icons.verified_user,
                            size: 20,
                            color: factCheck.autoGenerated
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SelectableText(
                              factCheck.autoGenerated
                                  ? 'Această verificare a fost generată automat folosind inteligență artificială și validată conform standardelor noastre.'
                                  : 'Această verificare a fost realizată manual de echipa noastră de experți.',
                              textAlign: TextAlign.justify,
                              style: textTheme.bodyMedium?.copyWith(
                                color: factCheck.autoGenerated
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onTertiaryContainer,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(BuildContext context, FactCheck factCheck) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informații',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildMetadataRow(
          context,
          'Data publicării',
          _formatDate(factCheck.publishedAt),
          Icons.calendar_today,
        ),
        const SizedBox(height: 8),
        _buildMetadataRow(
          context,
          'Tip verificare',
          factCheck.autoGenerated ? 'Automată' : 'Manuală',
          Icons.settings,
        ),
        const SizedBox(height: 8),
        _buildMetadataRow(context, 'ID Verificare', factCheck.id, Icons.tag),
      ],
    );
  }

  Widget _buildMetadataRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, FactCheck factCheck) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _shareFactCheck(factCheck),
          icon: const Icon(Icons.share),
          label: const Text('Distribuie fact-check-ul'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // Navighez direct la formularul de informație incorectă cu ID-ul pre-completat
            context.push(
              '/support/form?category=incorrectInfo&factCheckId=${factCheck.id}',
            );
          },
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Raportează informație incorectă'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSources(BuildContext context, FactCheck factCheck) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Surse',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${factCheck.sources!.length} surse verificate',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista surselor cu link-uri clickabile
              ...factCheck.sources!.asMap().entries.map((entry) {
                final index = entry.key;
                final source = entry.value;
                final isLink = source.contains('http');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: isLink
                                      ? () => _launchURL(source)
                                      : null,
                                  child: Text(
                                    source,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isLink
                                              ? Colors.blue.shade700
                                              : Colors.grey.shade800,
                                          decoration: isLink
                                              ? TextDecoration.underline
                                              : null,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                if (isLink) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.open_in_new,
                                        size: 14,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Click pentru a deschide',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Informații despre verificare
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informații',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Data verificării',
                      _formatDate(factCheck.publishedAt),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      context,
                      'Tip verificare',
                      factCheck.autoGenerated ? 'Automată (AI)' : 'Manuală',
                      factCheck.autoGenerated ? Icons.smart_toy : Icons.person,
                    ),
                    if (factCheck.autoGenerated) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sursele au fost verificate automat de AI',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ianuarie',
      'februarie',
      'martie',
      'aprilie',
      'mai',
      'iunie',
      'iulie',
      'august',
      'septembrie',
      'octombrie',
      'noiembrie',
      'decembrie',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Metodă pentru a deschide URL-uri
  void _launchURL(String source) async {
    // Extrag URL-ul din sursa care are formatul "Titlu - URL"
    final parts = source.split(' - ');
    if (parts.length >= 2) {
      final url = parts.last.trim();
      if (url.startsWith('http')) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback pentru când nu se poate deschide URL-ul
          debugPrint('Nu se poate deschide URL-ul: $url');
        }
      }
    }
  }
}
