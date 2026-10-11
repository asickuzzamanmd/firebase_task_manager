import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // High, Medium, Low
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: data['priority'] ?? 'Low',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }
}