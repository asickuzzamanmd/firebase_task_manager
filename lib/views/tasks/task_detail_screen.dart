import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/firestore_service.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    Color getPriorityColor(String priority) {
      switch (priority.toLowerCase()) {
        case 'high':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: task),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await firestoreService.deleteTask(task.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(
                    task.priority.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: getPriorityColor(task.priority),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    task.isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor: task.isCompleted ? Colors.teal : Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              task.description.isEmpty ? 'No description provided.' : task.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Due Date: ${DateFormat('dd MMMM yyyy').format(task.dueDate)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}