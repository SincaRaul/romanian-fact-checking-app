class Question {
  final String id;
  final String title;
  final String? body;
  final String status; // open, queued, checked
  final int votesCount;
  final DateTime createdAt;

  const Question({
    required this.id,
    required this.title,
    this.body,
    required this.status,
    required this.votesCount,
    required this.createdAt,
  });

  Question copyWith({
    String? id,
    String? title,
    String? body,
    String? status,
    int? votesCount,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      votesCount: votesCount ?? this.votesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      status: json['status'] as String,
      votesCount: json['votes_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'status': status,
      'votes_count': votesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Question(id: $id, title: $title, status: $status, votes: $votesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
