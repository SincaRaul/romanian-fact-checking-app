import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Onboarding state notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState.loading()) {
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool('onboarding_completed') ?? false;
      final selectedCategories =
          prefs.getStringList('selected_categories') ?? [];

      if (isCompleted) {
        state = OnboardingState.completed(selectedCategories);
      } else {
        state = const OnboardingState.notStarted();
      }
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }

  Future<void> completeOnboarding(List<String> selectedCategories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setStringList('selected_categories', selectedCategories);

      state = OnboardingState.completed(selectedCategories);
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_completed');
      await prefs.remove('selected_categories');

      state = const OnboardingState.notStarted();
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }

  Future<void> updateSelectedCategories(List<String> selectedCategories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_categories', selectedCategories);

      state = OnboardingState.completed(selectedCategories);
    } catch (e) {
      state = OnboardingState.error(e.toString());
    }
  }
}

// Onboarding state
sealed class OnboardingState {
  const OnboardingState();

  const factory OnboardingState.loading() = OnboardingLoading;
  const factory OnboardingState.notStarted() = OnboardingNotStarted;
  const factory OnboardingState.completed(List<String> selectedCategories) =
      OnboardingCompleted;
  const factory OnboardingState.error(String message) = OnboardingError;
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingNotStarted extends OnboardingState {
  const OnboardingNotStarted();
}

class OnboardingCompleted extends OnboardingState {
  final List<String> selectedCategories;
  const OnboardingCompleted(this.selectedCategories);
}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);
}

// Provider
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(),
    );

// Helper provider for selected categories
final selectedCategoriesProvider = Provider<List<String>>((ref) {
  final onboardingState = ref.watch(onboardingProvider);
  return switch (onboardingState) {
    OnboardingCompleted(:final selectedCategories) => selectedCategories,
    _ => [],
  };
});
