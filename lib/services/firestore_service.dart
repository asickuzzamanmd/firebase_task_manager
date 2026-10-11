import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final CollectionReference _taskRef =
  FirebaseFirestore.instance.collection('tasks');

  // Add Task
  Future<void> addTask(TaskModel task) async {
    await _taskRef.add(task.toMap());
  }

  // Get User Tasks Stream (Index ছাড়া সরাসরি ডেটা আসবে)
  Stream<List<TaskModel>> getTasks(String userId) {
    return _taskRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList());
  }

  // Update Task
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    await _taskRef.doc(taskId).update(data);
  }

  // Toggle Completion
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _taskRef.doc(taskId).update({'isCompleted': isCompleted});
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await _taskRef.doc(taskId).delete();
  }
}