import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/onboarding_providers.dart';
import 'screens/fact_check_details_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';
import 'screens/explore_screen.dart';
import 'screens/ask_screen.dart';
import 'screens/profile_screen.dart';
import 'features/home/new_home_screen.dart';
import 'features/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);

    final router = GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        // Simplified redirect logic
        if (onboardingState is OnboardingNotStarted) {
          if (state.matchedLocation != '/onboarding') {
            return '/onboarding';
          }
        } else if (onboardingState is OnboardingCompleted) {
          if (state.matchedLocation == '/onboarding') {
            return '/home';
          }
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              MainShell(location: state.uri.toString(), child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const NewHomeScreen(),
            ),
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) => const ExploreScreen(),
            ),
            GoRoute(
              path: '/ask',
              name: 'ask',
              builder: (context, state) => const AskScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/details/:id',
              name: 'details',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return FactCheckDetailsScreen(factCheckId: id);
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Fact Check România',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) {
        // Show loading screen while checking onboarding status
        return switch (onboardingState) {
          OnboardingLoading() => const _LoadingScreen(),
          _ => child ?? const SizedBox(),
        };
      },
    );
  }
}

// Loading screen widget
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Fact Check România',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Se încarcă...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
