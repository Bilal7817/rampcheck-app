class Attachment {
  final int? id;
  final int jobId;
  final String fileName;
  final String filePath;
  final String fileType;
  final DateTime createdAt;
  final int needsSync;

  Attachment({
    this.id,
    required this.jobId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.createdAt,
    this.needsSync = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'created_at': createdAt.toIso8601String(),
      'needs_sync': needsSync,
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as int?,
      jobId: map['job_id'] as int,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      needsSync: map['needs_sync'] as int? ?? 1,
    );
  }

  Attachment copyWith({
    int? id,
    int? jobId,
    String? fileName,
    String? filePath,
    String? fileType,
    DateTime? createdAt,
    int? needsSync,
  }) {
    return Attachment(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
