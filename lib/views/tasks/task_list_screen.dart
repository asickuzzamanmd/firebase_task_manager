import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Bonus: Search & Filter state variables
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Pending', 'Completed'
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Bonus Task 1: Delete confirmation dialog
  void _confirmDelete(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _firestoreService.deleteTask(taskId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Bonus Task: Color indication based on Priority
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim().toLowerCase();
            });
          },
        )
            : const Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bonus Task 2: Filter Tabs (All, Pending, Completed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Task List StreamBuilder
          Expanded(
            child: userId.isEmpty
                ? const Center(child: Text('User not logged in!'))
                : StreamBuilder<List<TaskModel>>(
              stream: _firestoreService.getTasks(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                List<TaskModel> tasks = snapshot.data ?? [];

                // 1. Status Filter apply
                if (_selectedFilter == 'Pending') {
                  tasks = tasks.where((t) => !t.isCompleted).toList();
                } else if (_selectedFilter == 'Completed') {
                  tasks = tasks.where((t) => t.isCompleted).toList();
                }

                // 2. Search Query apply
                if (_searchQuery.isNotEmpty) {
                  tasks = tasks.where((t) {
                    final titleMatch = t.title.toLowerCase().contains(_searchQuery);
                    final descMatch = t.description.toLowerCase().contains(_searchQuery);
                    return titleMatch || descMatch;
                  }).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks found!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (val) {
                            _firestoreService.toggleTaskStatus(
                              task.id,
                              val ?? false,
                            );
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Text(task.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(task.priority).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: _getPriorityColor(task.priority)),
                                  ),
                                  child: Text(
                                    task.priority,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getPriorityColor(task.priority),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Due: ${DateFormat('dd MMM yyyy').format(task.dueDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
      ),
    );
  }
}