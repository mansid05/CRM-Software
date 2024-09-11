import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_task_page.dart';

class TaskPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  TaskPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = tasksJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    tasksJson.removeAt(index); // Remove the task from the list
    await prefs.setStringList('tasks', tasksJson); // Save updated list

    setState(() {
      _tasks.removeAt(index); // Update UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                  ),
                ),
              ).then((_) => _fetchTasks()); // Refresh tasks after adding a new one
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Tasks',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchTasks,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${task['first_name']} ${task['last_name']}'),
                    subtitle: Text(task['subject'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailPage(task: task),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFF7b68ee)),
                  onPressed: () async {
                    final shouldDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Task'),
                        content: Text('Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete) {
                      _deleteTask(index);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TaskDetailPage extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskDetailPage({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('${task['first_name'] ?? 'Unknown'} ${task['last_name'] ?? 'Unknown'}', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Subject', task['subject'] ?? 'N/A'),
            _buildDetailRow('Due Date', task['due_date'] ?? 'N/A'),
            _buildDetailRow('Contact', task['contact'] ?? 'N/A'),
            _buildDetailRow('Account', task['account'] ?? 'N/A'),
            _buildDetailRow('Status', task['status'] ?? 'N/A'),
            _buildDetailRow('Priority', task['priority'] ?? 'N/A'),
            _buildDetailRow('Send Notification Email', task['send_notification_email'] == '1' ? 'Yes' : 'No'),
            _buildDetailRow('Remainder', task['remainder'] ?? 'N/A'),
            _buildDetailRow('Repeat', task['repeat'] ?? 'N/A'),
            _buildDetailRow('Description', task['description'] ?? 'N/A'),

          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}