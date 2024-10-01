import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
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
    try {
      final response = await http.get(Uri.parse(getTasksUrl));

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final List<dynamic> tasksJson = json.decode(response.body);

        setState(() {
          _tasks = tasksJson.cast<Map<String, dynamic>>();
        });

        if (_tasks.isEmpty) {
          print('No tasks found');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e'); // Will display any connection or parsing errors
    }
  }

  //Future<void> _deleteTask(int id) async {
  //     try {
  //       final response = await http.post(
  //         Uri.parse(deleteTaskUrl),
  //       body: json.encode({'id': id}),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _tasks.removeWhere((task) => task['id'] == id);
  //       });
  //     } else {
  //       print('Failed to delete task');
  //     }
  //   } catch (e) {
  //     print('Error deleting task: $e');
  //   }
  // }

  Future<void> _showTaskDetails(Map<String, dynamic> task) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => TaskDetailSheet(task: task),
    );
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
                    title: Text(task['task_owner']),
                    subtitle: Text(task['subject'] ?? ''),
                    leading: CircleAvatar(
                      child: Icon(Icons.task, size: 40, color: Colors.white),
                      backgroundColor: Color(0xFF7b68ee),
                    ),
                    onTap: () {
                      _showTaskDetails(task);
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
                      //_deleteTask(index);
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

class TaskDetailSheet extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskDetailSheet({required this.task});

  
  @override
  Widget build(BuildContext context) {
    return Padding(
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