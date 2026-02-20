class IssueModel {
  String? id;
  String title;
  String description;
  IssueCategory category;
  IssueStatus status;
  IssuePriority priority;
  String location;
  String? photoUrl;
  String reportedBy;
  String? assignedTo;
  int? estimatedTime;
  int? actualTime;
  String? resolutionNotes;
  String? completionPhotoUrl;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? assignedAt;
  DateTime? startedAt;
  DateTime? resolvedAt;

  IssueModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.location,
    this.photoUrl,
    required this.reportedBy,
    this.assignedTo,
    this.estimatedTime,
    this.actualTime,
    this.resolutionNotes,
    this.completionPhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.assignedAt,
    this.startedAt,
    this.resolvedAt,
  });
factory IssueModel.fromMap(Map<String, dynamic> map) {
  return IssueModel(
    id: map['id']?.toString(),
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    category: IssueCategory.values.firstWhere(
      (e) => e.name == map['category'],
      orElse: () => IssueCategory.IT,
    ),
    status: IssueStatus.values.firstWhere(
      (e) =>
          e.name == map['status'] ||
          (map['status'] == 'In Progress' && e == IssueStatus.InProgress),
      orElse: () => IssueStatus.Pending,
    ),
    priority: IssuePriority.values.firstWhere(
      (e) => e.name == map['priority'],
      orElse: () => IssuePriority.Low,
    ),
    location: map['location'] ?? '',
    photoUrl: map['photo_url'],
    reportedBy: map['reported_by'] ?? '',
    assignedTo: map['assigned_to'],
    estimatedTime: map['estimated_time'],
    actualTime: map['actual_time'],
    resolutionNotes: map['resolution_notes'],
    completionPhotoUrl: map['completion_photo_url'],
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'])
        : null,
    assignedAt: map['assigned_at'] != null
        ? DateTime.parse(map['assigned_at'])
        : null,
    startedAt: map['started_at'] != null
        ? DateTime.parse(map['started_at'])
        : null,
    resolvedAt: map['resolved_at'] != null
        ? DateTime.parse(map['resolved_at'])
        : null,
  );
}
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'status': status == IssueStatus.InProgress
          ? 'In Progress'
          : status.name,
      'priority': priority.name,
      'location': location,
      'photo_url': photoUrl,
      'reported_by': reportedBy,
      'assigned_to': assignedTo,
      'estimated_time': estimatedTime,
      'actual_time': actualTime,
      'resolution_notes': resolutionNotes,
      'completion_photo_url': completionPhotoUrl,
    };
  }
}

enum IssuePriority {
  Low,
  Medium,
  High,
  Urgent,
}

enum IssueStatus {
  Pending,
  Assigned,
  InProgress,
  Resolved,
  Rejected,
  Escalated,
}

enum IssueCategory {
  IT,
  Facilities,
  Cleaning,
  Security,
  Plumbing,
  Electrical,
  Other,
}
