// lib/features/home/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeframe.dart';

final timeframeProvider = StateProvider<Timeframe>((_) => Timeframe.today);

// Mock provider pentru statistici - poate fi înlocuit cu unul real când adaugi endpoint
final statsProvider = StateProvider<Map<String, dynamic>>((ref) {
  final timeframe = ref.watch(timeframeProvider);

  // Mock data bazată pe timeframe
  switch (timeframe) {
    case Timeframe.today:
      return {'newCount': 15, 'truePct': 35, 'falsePct': 22};
    case Timeframe.week:
      return {'newCount': 127, 'truePct': 32, 'falsePct': 28};
    case Timeframe.month:
      return {'newCount': 489, 'truePct': 30, 'falsePct': 31};
  }
});
