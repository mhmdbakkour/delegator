import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late TaskStatus _status;

  AppUser? _assignedUser;
  List<AppUser> _users = [];
  AppUser? _selectedUser;
  bool _creatingUser = false;
  String _newUsername = '';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;
    _status = widget.task.status;
    _assignedUser = widget.task.assignedUser;
    _selectedUser = widget.task.assignedUser;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _apiService.fetchUsers();
    if (!mounted) return;

    setState(() {
      _users = users;
      if (_assignedUser != null) {
        _assignedUser = _users.firstWhere(
          (u) => u.id == _assignedUser!.id, // or u.username
          orElse: () => _assignedUser!,
        );
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      AppUser? assignedUser = _selectedUser;

      if (_creatingUser) {
        assignedUser = await _apiService.createUser(_newUsername);
      }

      final updatedTask = widget.task.copyWith(
        title: _title,
        description: _description,
        status: _status,
        assignedUser: assignedUser,
      );

      print(updatedTask.toJson());

      await _apiService.updateTask(updatedTask);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task updated')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: ColorScheme.of(context).secondary,
        foregroundColor: ColorScheme.of(context).onSecondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (v) => _description = v?.trim() ?? '',
              ),
              const SizedBox(height: 24),

              Text('Status', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<TaskStatus>(
                segments: TaskStatus.values
                    .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                    .toList(),
                selected: {_status},
                onSelectionChanged: (value) {
                  setState(() => _status = value.first);
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Assigned User',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_creatingUser ? Icons.person_add : Icons.person),
                title: DropdownMenu<AppUser?>(
                  key: ValueKey(
                    _assignedUser,
                  ), // Forces rebuild when user is found/loaded
                  initialSelection: _assignedUser,
                  expandedInsets: EdgeInsets.zero,
                  hintText: "Select User",
                  dropdownMenuEntries: [
                    ..._users.map(
                      (u) => DropdownMenuEntry<AppUser?>(
                        value: u,
                        label: u.username,
                      ),
                    ),
                    const DropdownMenuEntry<AppUser?>(
                      value: null,
                      label: 'Create new user',
                      trailingIcon: Icon(Icons.add_circle),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == null) {
                      setState(() {
                        _creatingUser = true;
                        _selectedUser = null;
                        _assignedUser =
                            null; // Clear so the dropdown doesn't look stuck
                      });
                    } else {
                      setState(() {
                        _creatingUser = false;
                        _selectedUser = value;
                        _assignedUser = value;
                      });
                    }
                  },
                ),
                trailing: _assignedUser != null
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            _assignedUser = null;
                            _selectedUser = null;
                          });
                        },
                        child: const Text('Unassign'),
                      )
                    : null,
              ),

              if (_creatingUser) ...[
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'New username',
                    icon: Icon(Icons.person_add_alt),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter username' : null,
                  onSaved: (v) => _newUsername = v!.trim(),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
