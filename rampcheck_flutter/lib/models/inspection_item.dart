class InspectionItem {
  final int? id;
  final int jobId;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? notes;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int needsSync;

  InspectionItem({
    this.id,
    required this.jobId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.notes,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'needs_sync': needsSync,
    };
  }

  factory InspectionItem.fromMap(Map<String, dynamic> map) {
    return InspectionItem(
      id: map['id'],
      jobId: map['job_id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1,
      notes: map['notes'],
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      needsSync: map['needs_sync'] ?? 0,
    );
  }

  InspectionItem copyWith({
    int? id,
    int? jobId,
    String? title,
    String? description,
    bool? isCompleted,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? needsSync,
  }) {
    return InspectionItem(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
