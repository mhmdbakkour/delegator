import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const TaskAssignmentApp());
}

class TaskAssignmentApp extends StatelessWidget {
  const TaskAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delegator',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
