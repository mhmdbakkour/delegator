import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../services/api_service.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;
  TaskStatus? _filterStatus;

  Icon _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaskStatus.inProgress:
        return const Icon(Icons.timelapse, color: Colors.orange);
      default:
        return const Icon(Icons.radio_button_unchecked, color: Colors.blue);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tasks = await _apiService.fetchTasks(status: _filterStatus);
      setState(() {
        _tasks = tasks;
        print(tasks[0].toJson());
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      _loadTasks();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        centerTitle: true,
        backgroundColor: ColorScheme.of(context).primary,
        foregroundColor: ColorScheme.of(context).onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<TaskStatus?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: TaskStatus.todo, label: Text('To Do')),
                ButtonSegment(
                  value: TaskStatus.inProgress,
                  label: Text('In Progress'),
                ),
                ButtonSegment(value: TaskStatus.done, label: Text('Done')),
              ],
              selected: {_filterStatus},
              onSelectionChanged: (value) {
                setState(() => _filterStatus = value.first);
                _loadTasks();
              },
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                ? const Center(child: Text('No tasks found'))
                : RefreshIndicator(
                    onRefresh: _loadTasks,
                    child: ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: _statusIcon(task.status),
                            title: Text(task.title),
                            subtitle: Text(
                              'Status: ${task.status.label}\n'
                              'Assigned: ${task.assignedUser?.username ?? "Unassigned"}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(task.id),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(task: task),
                                ),
                              );
                              _loadTasks();
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
