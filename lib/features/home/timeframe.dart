// lib/features/home/timeframe.dart
enum Timeframe { today, week, month }

extension TimeframeLabel on Timeframe {
  String get label => switch (this) {
    Timeframe.today => 'Azi',
    Timeframe.week => '7 zile',
    Timeframe.month => '30 zile',
  };
}
