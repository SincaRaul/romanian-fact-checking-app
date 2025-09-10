// lib/screens/support/support_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/support_category.dart';
import '../../services/support_service.dart';
import '../../providers/fact_check_providers.dart';

class SupportFormScreen extends ConsumerStatefulWidget {
  final SupportCategory category;
  final String? factCheckId;

  const SupportFormScreen({
    super.key,
    required this.category,
    this.factCheckId,
  });

  @override
  ConsumerState<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends ConsumerState<SupportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();
  final _emailController = TextEditingController();
  final _factCheckIdController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-completez ID-ul fact-check-ului dacă este furnizat
    if (widget.factCheckId != null) {
      _factCheckIdController.text = widget.factCheckId!;
      if (widget.category == SupportCategory.incorrectInfo) {
        _descriptionController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _sourceController.dispose();
    _emailController.dispose();
    _factCheckIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCategoryInfoCard(context),
            const SizedBox(height: 24),

            if (widget.category == SupportCategory.incorrectInfo) ...[
              _buildFactCheckIdField(context),
              const SizedBox(height: 16),
            ],

            // Description field
            _buildDescriptionField(context),
            const SizedBox(height: 16),

            if (widget.category.requiresSource) ...[
              _buildSourceField(context),
              const SizedBox(height: 16),
            ],

            _buildEmailField(context),
            const SizedBox(height: 32),

            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(widget.category.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.category.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactCheckIdField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Fact-Check (auto-completat)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID-ul fact-check-ului pentru care raportezi problema.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _factCheckIdController,
          readOnly:
              widget.factCheckId != null, // Read-only dacă e pre-completat
          decoration: InputDecoration(
            hintText: 'ID-ul fact-check-ului',
            prefixIcon: const Icon(Icons.numbers),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: widget.factCheckId != null,
            fillColor: widget.factCheckId != null
                ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Te rugăm să introduci ID-ul fact-check-ului';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrierea problemei *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: _getDescriptionHint(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Te rugăm să descrii problema';
            }
            if (value.trim().length < 10) {
              return 'Descrierea trebuie să aibă cel puțin 10 caractere';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSourceField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link sursă (obligatoriu) *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Te rugăm să incluzi un link către o sursă credibilă care demonstrează informația corectă.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sourceController,
          decoration: InputDecoration(
            hintText: 'https://exemplu.com/articol-corect',
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Sursa este obligatorie pentru raportarea informației incorecte';
            }
            final uri = Uri.tryParse(value);
            if (uri == null || !uri.hasAbsolutePath) {
              return 'Te rugăm să introduci un link valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email (opțional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pentru a primi actualizări despre statusul raportului tău.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'exemplu@email.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Te rugăm să introduci un email valid';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: _isSubmitting ? null : _submitForm,
      icon: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send),
      label: Text(_isSubmitting ? 'Se trimite...' : 'Trimite raportul'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  String _getDescriptionHint() {
    switch (widget.category) {
      case SupportCategory.incorrectInfo:
        return 'Descrie ce informație este incorectă și care ar trebui să fie informația corectă...';
      case SupportCategory.bugReport:
        return 'Descrie pașii pentru a reproduce problema, ce ai așteptat să se întâmple și ce s-a întâmplat în realitate...';
      case SupportCategory.featureRequest:
        return 'Descrie funcționalitatea pe care ți-ai dori-o și de ce ar fi utilă...';
      case SupportCategory.generalQuestion:
        return 'Pune-ți întrebarea aici...';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final supportService = SupportService(apiService);

      await supportService.submitSupportTicket(
        category: widget.category,
        description: _descriptionController.text.trim(),
        sourceUrl: widget.category.requiresSource
            ? _sourceController.text.trim()
            : null,
        userEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        factCheckId: _factCheckIdController.text.trim().isEmpty
            ? null
            : _factCheckIdController.text.trim(),
      );

      if (mounted) {
        // Navigăm înapoi la categoria de support și apoi la home
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Raportul a fost trimis cu succes!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'OK',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la trimiterea raportului: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
}
