import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/task.dart';
import '../models/task_status.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://mhmdbakkour.atwebpages.com/task_api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // GET all tasks
  Future<List<Task>> fetchTasks({TaskStatus? status}) async {
    final uri = status == null
        ? Uri.parse('$baseUrl/tasks.php')
        : Uri.parse('$baseUrl/tasks.php?status=${status.value}');

    final response = await _client.get(uri, headers: _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch tasks');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Task.fromJson(e)).toList();
  }

  // POST create new task
  Future<Task> createTask({
    required String title,
    required String description,
    AppUser? assignedUser, // new
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/tasks.php'),
      headers: _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'status': TaskStatus.todo.value,
        'assigned_user': assignedUser?.id, // send user ID if available
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create task');
    }

    return Task.fromJson(jsonDecode(response.body));
  }

  // PATCH update task
  Future<Task> updateTask(Task task) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/tasks.php?id=${task.id}'), // <-- pass id as GET param
      headers: _headers(),
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'status': task.status.value,
        'assigned_user': task.assignedUser?.id,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }

    return Task.fromJson(jsonDecode(response.body));
  }

  // DELETE task
  Future<void> deleteTask(int taskId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/tasks.php?id=$taskId'), // <-- pass id as GET param
      headers: _headers(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  Future<List<AppUser>> fetchUsers() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/users.php'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => AppUser.fromJson(e)).toList();
  }

  Future<AppUser> createUser(String username) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/users.php'),
      headers: _headers(),
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create user');
    }

    return AppUser.fromJson(jsonDecode(response.body));
  }

  Map<String, String> _headers() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }
}
