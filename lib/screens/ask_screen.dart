import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contextController = TextEditingController();
  final _sourceController = TextEditingController();

  String _selectedCategory = 'general';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    _sourceController.dispose();
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

            // Question Input
            _buildQuestionInput(),
            const SizedBox(height: 16),

            // Context Input
            _buildContextInput(),
            const SizedBox(height: 16),

            // Source Input
            _buildSourceInput(),
            const SizedBox(height: 16),

            // Category Selection
            _buildCategorySelection(),
            const SizedBox(height: 24),

            // Guidelines Section
            _buildGuidelines(context),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 16),

            // Recent Questions Section
            _buildRecentQuestions(context),
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
                Icons.help_center,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Solicită verificarea unei afirmații',
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
            'Ai întâlnit o informație suspectă? Solicită verificarea ei de către echipa noastră de experți.',
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
          'Afirmația de verificat *',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          maxLength: 200,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ex: "România are cel mai mare deficit bugetar din UE"',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.format_quote),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Te rog introdu afirmația de verificat';
            }
            if (value.trim().length < 10) {
              return 'Afirmația trebuie să aibă cel puțin 10 caractere';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Context suplimentar (opțional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Oferă mai multe detalii despre contextul în care ai întâlnit această afirmație',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contextController,
          maxLength: 500,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Ex: Am văzut această afirmație într-un articol de presă, pe o rețea socială...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info_outline),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sursa (opțional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Link către articol, postare socială sau alte surse',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sourceController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/articol',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
            filled: true,
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Te rog introdu un link valid';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
            filled: true,
          ),
          items: const [
            DropdownMenuItem(value: 'general', child: Text('🏛️ General')),
            DropdownMenuItem(value: 'politica', child: Text('🏛️ Politică')),
            DropdownMenuItem(value: 'economie', child: Text('💰 Economie')),
            DropdownMenuItem(value: 'sanatate', child: Text('🏥 Sănătate')),
            DropdownMenuItem(value: 'educatie', child: Text('🎓 Educație')),
            DropdownMenuItem(value: 'mediu', child: Text('🌱 Mediu')),
            DropdownMenuItem(value: 'tehnologie', child: Text('💻 Tehnologie')),
            DropdownMenuItem(value: 'sport', child: Text('⚽ Sport')),
            DropdownMenuItem(value: 'cultura', child: Text('🎭 Cultură')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value ?? 'general';
            });
          },
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                'Ghid pentru solicitări',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem(
            '✅ Fii specific și clar în formularea afirmației',
          ),
          _buildGuidelineItem(
            '✅ Oferă surse sau context atunci când este posibil',
          ),
          _buildGuidelineItem('✅ Evită întrebările de opinie sau subiective'),
          _buildGuidelineItem(
            '✅ Verifică dacă afirmația nu a fost deja verificată',
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSubmitting ? null : _submitRequest,
        icon: _isSubmitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: Text(_isSubmitting ? 'Se trimite...' : 'Trimite solicitarea'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentQuestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Solicitări recente',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.go('/explore'),
              child: const Text('Vezi toate'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...[1, 2, 3].map(
          (i) => _buildRecentQuestionCard(
            'Solicitare de exemplu #$i',
            'În curs de verificare',
            '${i}h',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentQuestionCard(String title, String status, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.schedule, color: Colors.orange.shade700, size: 20),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(status),
        trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Solicitarea a fost trimisă cu succes!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _titleController.clear();
        _contextController.clear();
        _sourceController.clear();
        setState(() => _selectedCategory = 'general');
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
        setState(() => _isSubmitting = false);
      }
    }
  }
}
