import '../models/fact_check.dart';
import 'package:flutter/material.dart';

extension VerdictExtension on Verdict {
  String get displayName {
    switch (this) {
      case Verdict.true_:
        return 'Adevărat';
      case Verdict.false_:
        return 'Fals';
      case Verdict.mixed:
        return 'Mixt';
      case Verdict.unclear:
        return 'Neclar';
    }
  }

  // Alias for displayName to match the UI code
  String toRoLabel() => displayName;

  String get icon {
    switch (this) {
      case Verdict.true_:
        return '✅';
      case Verdict.false_:
        return '❌';
      case Verdict.mixed:
        return '⚠️';
      case Verdict.unclear:
        return '❓';
    }
  }

  // Icon data for Flutter widgets
  IconData get iconData {
    switch (this) {
      case Verdict.true_:
        return Icons.check_circle;
      case Verdict.false_:
        return Icons.cancel;
      case Verdict.mixed:
        return Icons.warning;
      case Verdict.unclear:
        return Icons.help;
    }
  }

  // Color for verdict display
  Color get color {
    switch (this) {
      case Verdict.true_:
        return Colors.green;
      case Verdict.false_:
        return Colors.red;
      case Verdict.mixed:
        return Colors.orange;
      case Verdict.unclear:
        return Colors.grey;
    }
  }

  String get description {
    switch (this) {
      case Verdict.true_:
        return 'Informația este confirmată și verificată';
      case Verdict.false_:
        return 'Informația este falsă sau incorectă';
      case Verdict.mixed:
        return 'Informația conține elemente adevărate și false';
      case Verdict.unclear:
        return 'Nu există suficiente dovezi pentru o concluzie clară';
    }
  }
}
