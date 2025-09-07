enum SupportCategory {
  incorrectInfo,
  bugReport,
  featureRequest,
  generalQuestion,
}

extension SupportCategoryExtension on SupportCategory {
  String get title {
    switch (this) {
      case SupportCategory.incorrectInfo:
        return 'Informație Incorectă';
      case SupportCategory.bugReport:
        return 'Bug Aplicație';
      case SupportCategory.featureRequest:
        return 'Cerere Funcționalitate';
      case SupportCategory.generalQuestion:
        return 'Întrebare Generală';
    }
  }

  String get description {
    switch (this) {
      case SupportCategory.incorrectInfo:
        return 'Raportează informații false sau incomplete găsite în aplicație';
      case SupportCategory.bugReport:
        return 'Raportează o problemă tehnică sau de performanță';
      case SupportCategory.featureRequest:
        return 'Sugerează o funcționalitate nouă';
      case SupportCategory.generalQuestion:
        return 'Pune o întrebare despre aplicație';
    }
  }

  String get icon {
    switch (this) {
      case SupportCategory.incorrectInfo:
        return '🚫';
      case SupportCategory.bugReport:
        return '🐛';
      case SupportCategory.featureRequest:
        return '💡';
      case SupportCategory.generalQuestion:
        return '❓';
    }
  }

  bool get requiresSource {
    return this == SupportCategory.incorrectInfo;
  }
}
