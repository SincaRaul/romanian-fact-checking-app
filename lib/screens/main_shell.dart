import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _calculateSelectedIndex(String location) {
    // Parsez URI-ul pentru a obține parametrii
    final uri = Uri.parse(location);

    // Verific path-ul principal
    if (uri.path.startsWith('/home')) return 0;
    if (uri.path.startsWith('/explore')) return 1;
    if (uri.path.startsWith('/ask')) return 2;
    if (uri.path.startsWith('/profile')) return 3;

    // Pentru pagina de detalii, verific parametrul 'from'
    if (uri.path.startsWith('/details')) {
      final fromPage = uri.queryParameters['from'] ?? 'home';
      switch (fromPage) {
        case 'explore':
          return 1; // Tab Explore
        case 'home':
        default:
          return 0; // Tab Home
      }
    }

    return 0; // Default la Home
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/ask');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(widget.location),
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Acasă',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorează',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_comment_outlined),
            selectedIcon: Icon(Icons.add_comment),
            label: 'Întreabă',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
