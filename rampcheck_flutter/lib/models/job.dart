class Job {
  final int? id;
  final String title;
  final String? description;
  final String? aircraftRegistration;
  final String status;
  final String priority;
  final int? assignedTechnicianId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int needsSync;

  Job({
    this.id,
    required this.title,
    this.description,
    this.aircraftRegistration,
    this.status = 'open',
    this.priority = 'medium',
    this.assignedTechnicianId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.needsSync = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'aircraft_registration': aircraftRegistration,
      'status': status,
      'priority': priority,
      'assigned_technician_id': assignedTechnicianId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'needs_sync': needsSync,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      aircraftRegistration: map['aircraft_registration'],
      status: map['status'] ?? 'open',
      priority: map['priority'] ?? 'medium',
      assignedTechnicianId: map['assigned_technician_id'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      needsSync: map['needs_sync'] ?? 0,
    );
  }

  Job copyWith({
    int? id,
    String? title,
    String? description,
    String? aircraftRegistration,
    String? status,
    String? priority,
    int? assignedTechnicianId,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? needsSync,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
