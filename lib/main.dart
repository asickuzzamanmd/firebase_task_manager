import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'views/auth/login_screen.dart';
import 'views/tasks/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Task Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const TaskListScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}