import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import 'admin_providers.dart';

class CreateFactCheckScreen extends ConsumerStatefulWidget {
  const CreateFactCheckScreen({super.key});

  @override
  ConsumerState<CreateFactCheckScreen> createState() =>
      _CreateFactCheckScreenState();
}

class _CreateFactCheckScreenState extends ConsumerState<CreateFactCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _sourcesController = TextEditingController();

  String _selectedVerdict = 'true';
  int _confidence = 95;
  String _selectedCategory = 'other';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'football',
    'politics_internal',
    'politics_external',
    'bills',
    'health',
    'technology',
    'environment',
    'economy',
    'other',
  ];

  final Map<String, String> _categoryLabels = {
    'football': 'Fotbal',
    'politics_internal': 'Politică Internă',
    'politics_external': 'Politică Externă',
    'bills': 'Facturi și Utilități',
    'health': 'Sănătate',
    'technology': 'Tehnologie',
    'environment': 'Mediu',
    'economy': 'Economie',
    'other': 'Altele',
  };

  final Map<String, String> _verdictLabels = {
    'true': 'Adevărat',
    'false': 'Fals',
    'mixed': 'Mixt',
    'unclear': 'Neclar',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _sourcesController.dispose();
    super.dispose();
  }

  Future<void> _submitFactCheck() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Parsez sursele din text (una pe linie)
      final sourceLines = _sourcesController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final newFactCheck = {
        'title': _titleController.text.trim(),
        'summary': _summaryController.text.trim(),
        'verdict': _selectedVerdict,
        'confidence': _confidence,
        'category': _selectedCategory,
        'sources': sourceLines,
      };

      final apiService = ApiService();
      await apiService.createAdminFactCheck(newFactCheck);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fact-check creat cu succes!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la crearea fact-check-ului: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verific dacă utilizatorul este în modul admin
    final isAdminMode = ref.watch(isAdminProvider);

    if (!isAdminMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acces interzis')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Nu aveți acces la această pagină',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text('Trebuie să fiți în modul admin.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creează Fact-Check'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () async {
              // Buton pentru a ieși din modul admin
              final adminAuth = ref.read(adminAuthProvider);
              await adminAuth.logout();
              if (context.mounted) context.pop();
            },
            tooltip: 'Ieși din modul admin',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titlu
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titlu *',
                  border: OutlineInputBorder(),
                  helperText:
                      'Titlul fact-check-ului (ex: "România s-a calificat la EURO 2024?")',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Titlul este obligatoriu';
                  }
                  if (value.trim().length < 10) {
                    return 'Titlul trebuie să aibă cel puțin 10 caractere';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Verdict
              DropdownButtonFormField<String>(
                initialValue: _selectedVerdict,
                decoration: const InputDecoration(
                  labelText: 'Verdict *',
                  border: OutlineInputBorder(),
                ),
                items: _verdictLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedVerdict = value!),
              ),
              const SizedBox(height: 16),

              // Confidence
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Încredere: $_confidence%'),
                  Slider(
                    value: _confidence.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$_confidence%',
                    onChanged: (value) =>
                        setState(() => _confidence = value.round()),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Categorie
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categorie *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_categoryLabels[category] ?? category),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),

              // Summary
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Rezumat *',
                  border: OutlineInputBorder(),
                  helperText: 'Explicația detaliată a fact-check-ului',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rezumatul este obligatoriu';
                  }
                  if (value.trim().length < 50) {
                    return 'Rezumatul trebuie să aibă cel puțin 50 de caractere';
                  }
                  return null;
                },
                maxLines: 8,
              ),
              const SizedBox(height: 16),

              // Sources
              TextFormField(
                controller: _sourcesController,
                decoration: const InputDecoration(
                  labelText: 'Surse',
                  border: OutlineInputBorder(),
                  helperText:
                      'O sursă pe linie (ex: "Știri oficiale - https://example.com")',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFactCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Se creează...'),
                        ],
                      )
                    : const Text(
                        'Creează Fact-Check',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
