class Category {
  final String id;
  final String label;
  final String icon;

  const Category({required this.id, required this.label, required this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'icon': icon};
  }
}
