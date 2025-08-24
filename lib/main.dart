import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/fact_check_providers.dart';
import 'models/fact_check.dart';
import 'utils/verdict_extensions.dart';
import 'screens/fact_check_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'details/:id',
              name: 'details',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return FactCheckDetailsScreen(factCheckId: id);
              },
            ),
            GoRoute(
              path: 'ask',
              name: 'ask',
              builder: (context, state) => const AskPage(),
            ),
            GoRoute(
              path: 'question/:id',
              name: 'question',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return QuestionDetailsPage(id: id);
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Factual Clone',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String query = '';
  Verdict? selectedVerdict;

  @override
  Widget build(BuildContext context) {
    final asyncChecks = ref.watch(latestFactChecksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ultimele verificări')),
      body: Column(
        children: [
          // SEARCH + FILTER BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Caută afirmații…',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        setState(() => query = v.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<Verdict?>(
                  value: selectedVerdict,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Toate')),
                    DropdownMenuItem(
                      value: Verdict.true_,
                      child: Text('Adevărat'),
                    ),
                    DropdownMenuItem(
                      value: Verdict.false_,
                      child: Text('Fals'),
                    ),
                    DropdownMenuItem(value: Verdict.mixed, child: Text('Mixt')),
                    DropdownMenuItem(
                      value: Verdict.unclear,
                      child: Text('Neclar'),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedVerdict = v),
                ),
              ],
            ),
          ),

          // LISTĂ
          Expanded(
            child: asyncChecks.when(
              data: (items) {
                var list = items;

                if (query.isNotEmpty) {
                  list = list
                      .where((c) => c.title.toLowerCase().contains(query))
                      .toList();
                }
                if (selectedVerdict != null) {
                  list = list
                      .where((c) => c.verdict == selectedVerdict)
                      .toList();
                }

                if (list.isEmpty) {
                  return const Center(child: Text('Nicio potrivire.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = list[i];
                    return Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: VerdictIcon(verdict: c.verdict),
                        title: Text(c.title),
                        subtitle: Text(
                          '${c.verdict.toRoLabel()} • ${_formatDate(c.publishedAt)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/details/${c.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Eroare: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ask'),
        icon: const Icon(Icons.add_comment),
        label: const Text('Adaugă întrebare'),
      ),
    );
  }
}

class AskPage extends StatefulWidget {
  const AskPage({super.key});

  @override
  State<AskPage> createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adaugă întrebare')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              maxLength: 140,
              decoration: const InputDecoration(
                labelText: 'Titlu întrebare',
                hintText: 'Ex: „Este X adevărat despre Y?”',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Te rog scrie o întrebare'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contextCtrl,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Context (opțional)',
                hintText: 'Detalii, linkuri, surse…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Întrebare trimisă (mock)')),
                  );
                  context.pop();
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Trimite'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionDetailsPage extends ConsumerWidget {
  const QuestionDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCheck = ref.watch(factCheckByIdProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Detalii verificare #$id')),
      body: asyncCheck.when(
        data: (c) => c == null
            ? const Center(child: Text('Nu am găsit verificarea.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    c.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      VerdictIcon(verdict: c.verdict),
                      const SizedBox(width: 8),
                      Text(c.verdict.toRoLabel()),
                      const SizedBox(width: 16),
                      Text('Scor: ${c.confidence}/100'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Publicat: ${_formatDate(c.publishedAt)}'),
                  const SizedBox(height: 16),
                  const Text('Surse (mock):'),
                  const Text('1) https://exemplu.ro/articol'),
                  const Text('2) https://altasursa.ro/stire'),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Eroare: $e')),
      ),
    );
  }
}

class VerdictIcon extends StatelessWidget {
  const VerdictIcon({super.key, required this.verdict});
  final Verdict verdict;

  @override
  Widget build(BuildContext context) {
    switch (verdict) {
      case Verdict.true_:
        return const Icon(Icons.check_circle_outline, color: Colors.green);
      case Verdict.false_:
        return const Icon(Icons.cancel_outlined, color: Colors.red);
      case Verdict.mixed:
        return const Icon(Icons.change_circle_outlined, color: Colors.orange);
      case Verdict.unclear:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}

String _formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}
