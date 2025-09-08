import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_providers.dart';
import '../providers/fact_check_providers.dart';

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();

  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicită verificare'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            _buildHeaderSection(context),
            const SizedBox(height: 24),

            // Single Question Input (combines title + context)
            _buildQuestionInput(),
            const SizedBox(height: 16),

            // Category Selection (optional)
            _buildCategorySelection(),
            const SizedBox(height: 24),

            // Guidelines Section
            _buildGuidelines(context),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 32),

            // Recent Popular Questions (instead of "See All")
            _buildPopularQuestions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondaryContainer,
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verificare cu AI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Scrie orice afirmație și vei primi o verificare completă, generată instant cu inteligență artificială.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ce vrei să verifici? *',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _questionController,
          maxLength: 500,
          maxLines: 6,
          minLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Scrie aici ce vrei să verifici...\n\nExemplu: "Am auzit că România exportă mai mult gaz decât importă. Este adevărat? Care sunt cifrele exacte și de unde vin aceste informații?"',
            border: OutlineInputBorder(),
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Icon(Icons.help_outline),
            ),
            filled: true,
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Te rog să scrii întrebarea ta';
            }
            if (value.trim().length < 10) {
              return 'Întrebarea este prea scurtă. Te rog să oferi mai multe detalii.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorie (opțional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Ajută AI-ul să înțeleagă mai bine subiectul',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
              filled: true,
              hintText: 'Selectează categoria (opțional)',
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Nicio categorie selectată'),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 8),
                      Text(category.label),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, _) =>
              Text('Eroare la încărcarea categoriilor: $error'),
        ),
      ],
    );
  }

  Widget _buildGuidelines(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sfaturi pentru o verificare precisă',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem(
            '📝 Fii specific',
            'Cu cât oferi mai multe detalii, cu atât verificarea va fi mai precisă',
          ),
          _buildGuidelineItem(
            '🎯 Menționează sursa',
            'De unde ai auzit informația? (ex: "am citit pe Facebook că...")',
          ),
          _buildGuidelineItem(
            '❓ Pune întrebări clare',
            'Ce anume vrei să știi? Cifre exacte? Comparații? Confirmări?',
          ),
          _buildGuidelineItem(
            '⚡ Răspuns instant',
            'Vei primi verificarea completă în câteva secunde',
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submitQuestion,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Se generează verificarea...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text(
                    'Verifică cu AI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPopularQuestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Întrebări populare astăzi',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Mock popular questions - în viitor de la API
        _buildPopularQuestionCard(
          '⚽ România se califică la EURO 2024?',
          '25 voturi',
          () => _showFeatureComingSoonDialog(context),
        ),
        _buildPopularQuestionCard(
          '💰 Salariul minim crește la 2500 lei?',
          '18 voturi',
          () => _showFeatureComingSoonDialog(context),
        ),
        _buildPopularQuestionCard(
          '🏥 Vaccinurile COVID sunt obligatorii?',
          '12 voturi',
          () => _showFeatureComingSoonDialog(context),
        ),
      ],
    );
  }

  Widget _buildPopularQuestionCard(
    String question,
    String votes,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      votes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Track the question submission
      final analytics = ref.read(analyticsServiceProvider);
      analytics.trackQuestion(
        _questionController.text.trim(),
        _selectedCategory,
      );

      // Get the repository from provider
      final repository = ref.read(factCheckRepoProvider);

      // Generate fact-check using AI
      final newFactCheck = await repository.generateWithAI(
        question: _questionController.text.trim(),
        category: _selectedCategory,
      );

      if (mounted) {
        // Invalidate main providers - others will refresh automatically due to dependencies
        ref.invalidate(latestFactChecksProvider);
        ref.invalidate(personalizedFactChecksProvider);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Verificarea a fost generată cu succes!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _questionController.clear();
        setState(() {
          _selectedCategory = null;
        });

        // Redirect to the fact-check details page
        context.go('/details/${newFactCheck.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Eroare: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showFeatureComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.construction, size: 48, color: Colors.orange),
          title: const Text(
            'Funcționalitate în dezvoltare',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Această funcționalitate va fi implementată în curând! '
            'Pentru moment, poți introduce manual întrebarea ta în câmpul de mai sus.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Am înțeles'),
            ),
          ],
        );
      },
    );
  }
}
