import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_providers.dart';
import '../providers/category_providers.dart';
import '../providers/fact_check_providers.dart';
import '../models/category.dart';
import '../features/admin/admin_providers.dart';
import '../features/admin/admin_password_dialog.dart';
import 'support/support_category_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          _buildProfileHeader(context),
          const SizedBox(height: 24),

          // Statistics Section
          _buildStatisticsSection(context, ref),
          const SizedBox(height: 24),

          // Categories Section
          _buildCategoriesSection(
            context,
            ref,
            selectedCategories,
            categoriesAsync,
          ),
          const SizedBox(height: 24),

          // Settings Section
          _buildSettingsSection(context, ref),
          const SizedBox(height: 24),

          // Admin Section
          _buildAdminSection(context, ref),
          const SizedBox(height: 24),

          // About Section
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Utilizator Fact Check',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Membru din ${DateTime.now().year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🏆 Verificator Activ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, WidgetRef ref) {
    final userAnalytics = ref.watch(userAnalyticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistici',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        userAnalytics.when(
          data: (analytics) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.article,
                      title: 'Știri citite',
                      value: '${analytics['stories_read'] ?? 0}',
                      subtitle: 'articole',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.share,
                      title: 'Știri distribuite',
                      value: '${analytics['stories_shared'] ?? 0}',
                      subtitle: 'partajări',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.quiz,
                      title: 'Întrebări',
                      value: '${analytics['questions_submitted'] ?? 0}',
                      subtitle: 'trimise',
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.article,
                      title: 'Știri citite',
                      value: '...',
                      subtitle: 'se încarcă',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.share,
                      title: 'Știri distribuite',
                      value: '...',
                      subtitle: 'se încarcă',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.quiz,
                      title: 'Întrebări',
                      value: '...',
                      subtitle: 'se încarcă',
                    ),
                  ),
                ],
              ),
            ],
          ),
          error: (_, __) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.article,
                      title: 'Știri citite',
                      value: '0',
                      subtitle: 'eroare',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.share,
                      title: 'Știri distribuite',
                      value: '0',
                      subtitle: 'eroare',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.quiz,
                      title: 'Întrebări',
                      value: '0',
                      subtitle: 'eroare',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedCategories,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categoriile mele',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () =>
                  _showCategoriesDialog(context, ref, categoriesAsync),
              child: const Text('Editează'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          data: (categories) {
            final myCategories = categories
                .where((cat) => selectedCategories.contains(cat.id))
                .toList();

            if (myCategories.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nicio categorie selectată',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selectează categorii pentru a vedea content personalizat',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: myCategories
                  .map(
                    (category) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(
            'Eroare la încărcarea categoriilor',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setări',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          context,
          icon: Icons.dark_mode,
          title: 'Temă',
          subtitle: 'Sistem (Auto)',
          onTap: () => _showComingSoonSnackBar(context),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildAdminSection(BuildContext context, WidgetRef ref) {
    final isAdminMode = ref.watch(isAdminProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (!isAdminMode) ...[
          _buildSettingsItem(
            context,
            icon: Icons.admin_panel_settings,
            title: 'Modul Admin',
            subtitle: 'Accesează funcționalități admin',
            onTap: () => _showAdminPasswordDialog(context, ref),
          ),
        ] else ...[
          _buildSettingsItem(
            context,
            icon: Icons.add_circle,
            title: 'Creează Fact-Check',
            subtitle: 'Adaugă o verificare manuală',
            onTap: () => context.push('/admin/create-fact-check'),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.logout,
            title: 'Ieși din Admin',
            subtitle: 'Dezactivează modul admin',
            onTap: () => _exitAdminMode(context, ref),
          ),
        ],
      ],
    );
  }

  void _showAdminPasswordDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AdminPasswordDialog(
        onPasswordSubmit: (password) async {
          final adminAuth = ref.read(adminAuthProvider);
          final success = await adminAuth.login(password);
          if (success && context.mounted) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Modul admin activat!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Parolă incorectă!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _exitAdminMode(BuildContext context, WidgetRef ref) async {
    final adminAuth = ref.read(adminAuthProvider);
    await adminAuth.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modul admin dezactivat!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Despre',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          context,
          icon: Icons.info,
          title: 'Despre aplicație',
          subtitle: 'Fact Check România v1.0.0',
          onTap: () => _showAboutDialog(context),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.help,
          title: 'Ajutor și suport',
          subtitle: 'Contactează echipa noastră',
          onTap: () => _showSupportDialog(context),
        ),
      ],
    );
  }

  void _showCategoriesDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CategoriesDialog(categoriesAsync: categoriesAsync),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetează aplicația'),
        content: const Text(
          'Această acțiune va șterge toate preferințele salvate și te va duce înapoi la ecranul de onboarding. Ești sigur?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(onboardingProvider.notifier).resetOnboarding();
              Navigator.pop(context);
              context.go('/onboarding');
            },
            child: const Text('Resetează'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SupportCategoryScreen()),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Fact Check România',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.verified,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Fact Check România este o aplicație pentru verificarea informațiilor și combaterea dezinformării în spațiul public românesc.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Misiunea noastră este să promovăm transparența și să oferim cetățenilor români instrumente pentru a lua decizii informate.',
        ),
        const SizedBox(height: 12),
        const Text('Dezvoltat cu ❤️ în România'),
      ],
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Această funcționalitate va fi disponibilă în curând'),
      ),
    );
  }
}

class _CategoriesDialog extends ConsumerStatefulWidget {
  final AsyncValue<List<Category>> categoriesAsync;

  const _CategoriesDialog({required this.categoriesAsync});

  @override
  ConsumerState<_CategoriesDialog> createState() => _CategoriesDialogState();
}

class _CategoriesDialogState extends ConsumerState<_CategoriesDialog> {
  late Set<String> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = Set.from(ref.read(selectedCategoriesProvider));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editează categorii'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.categoriesAsync.when(
          data: (categories) => ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategories.contains(category.id);

              return CheckboxListTile(
                title: Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(category.label)),
                  ],
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedCategories.add(category.id);
                    } else {
                      selectedCategories.remove(category.id);
                    }
                  });
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Eroare la încărcarea categoriilor'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anulează'),
        ),
        FilledButton(
          onPressed: () async {
            await ref
                .read(onboardingProvider.notifier)
                .updateSelectedCategories(selectedCategories.toList());
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Salvează'),
        ),
      ],
    );
  }
}
