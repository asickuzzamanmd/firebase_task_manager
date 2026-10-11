import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = 'Low';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _selectedPriority = widget.task!.priority;
    }
  }

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final userId = AuthService().currentUser?.uid ?? '';
    final firestoreService = FirestoreService();

    if (widget.task == null) {
      final newTask = TaskModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _selectedDate,
        priority: _selectedPriority,
        isCompleted: false,
        createdAt: DateTime.now(),
        userId: userId,
      );
      await firestoreService.addTask(newTask);
    } else {
      await firestoreService.updateTask(widget.task!.id, {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'dueDate': _selectedDate,
        'priority': _selectedPriority,
      });
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: ['Low', 'Medium', 'High']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedPriority = val!),
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveTask, child: const Text('Save Task')),
          ],
        ),
      ),
    );
  }
}