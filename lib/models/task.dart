import 'task_status.dart';
import 'user.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final TaskStatus status;
  final AppUser? assignedUser;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedUser,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      status: TaskStatusX.fromString(json['status']),
      assignedUser: json['assigned_user'] != null
          ? AppUser.fromJson(json['assigned_user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'assigned_user': assignedUser?.toJson(),
    };
  }

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    AppUser? assignedUser,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedUser: assignedUser,
    );
  }
}
