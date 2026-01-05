import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart'; // Ensure this matches your project structure

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  bool _loading = false;

  // Added User Logic
  List<AppUser> _users = [];
  AppUser? _assignedUser;
  bool _creatingUser = true;
  String _newUsername = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _apiService.fetchUsers();
      setState(() => _users = users);
    } catch (e) {
      // Handle potential fetch error
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _loading = true;
    });

    try {
      AppUser? finalUser = _assignedUser;

      // If user chose to create a new one
      if (_creatingUser && _newUsername.isNotEmpty) {
        finalUser = await _apiService.createUser(_newUsername);
      }

      await _apiService.createTask(
        title: _title,
        description: _description,
        assignedUser: finalUser, // Passing the user ID to your service
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task created')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: ColorScheme.of(context).secondary,
        foregroundColor: ColorScheme.of(context).onSecondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            // Changed to ListView to prevent overflow when keyboard appears
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter title' : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),

              // Dropdown inside ListTile replaces the text label
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_creatingUser ? Icons.person_add : Icons.person),
                title: DropdownMenu<AppUser?>(
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
                      trailingIcon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      if (value == null) {
                        _creatingUser = true;
                        _assignedUser = null;
                      } else {
                        _creatingUser = false;
                        _assignedUser = value;
                      }
                    });
                  },
                ),
                trailing: _assignedUser != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _assignedUser = null),
                      )
                    : null,
              ),

              if (_creatingUser) ...[
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'New username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_add_alt),
                  ),
                  validator: (v) => _creatingUser && (v == null || v.isEmpty)
                      ? 'Enter username'
                      : null,
                  onSaved: (v) => _newUsername = v?.trim() ?? '',
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
