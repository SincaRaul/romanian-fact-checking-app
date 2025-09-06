import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/fact_check.dart';
import '../providers/fact_check_providers.dart';
import '../utils/verdict_extensions.dart';

class FactCheckDetailsScreen extends ConsumerWidget {
  final String factCheckId;

  const FactCheckDetailsScreen({super.key, required this.factCheckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factCheckAsync = ref.watch(factCheckByIdProvider(factCheckId));

    // Obțin parametrul 'from' pentru a ști unde să mă întorc
    final uri = GoRouterState.of(context).uri;
    final fromPage = uri.queryParameters['from'] ?? 'home';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii Fact-Check'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Mă întorc la pagina de unde am venit
            switch (fromPage) {
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
                Text(
                  'Încredere: ${factCheck.confidence}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: factCheck.verdict.color,
                  ),
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
        if (factCheck.autoGenerated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  'Generat automat',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 16, color: Colors.green.shade700),
              const SizedBox(width: 4),
              Text(
                'Verificat',
                style: TextStyle(
                  color: Colors.green.shade700,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explicație detaliată',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            // Pentru moment folosim titlul ca explicație
            // În viitor, backend-ul va avea câmp separat pentru summary/explanation
            'Această verificare se bazează pe surse oficiale și cercetări documentate. '
            '${factCheck.title}\n\n'
            'Gradul de încredere de ${factCheck.confidence}% reflectă calitatea '
            'și cantitatea surselor verificate pentru această afirmație.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
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
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcția de share va fi implementată'),
              ),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Distribuie fact-check-ul'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement report functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcția de raportare va fi implementată'),
              ),
            );
          },
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Raportează o problemă'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
}
