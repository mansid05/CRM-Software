import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../constants.dart';

Future<void> _saveTask(Map<String, dynamic> taskData) async {
  final response = await http.post(
    Uri.parse(saveTaskUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(taskData),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save lead');
  }
}

class AddTaskPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddTaskPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final addTaskFormKey = GlobalKey<_AddTaskFormState>(); // New key

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Task', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            onPressed: () {
              addTaskFormKey.currentState?.submitForm();
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddTaskForm(
            key: addTaskFormKey,
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      ),
    );
  }
}

class AddTaskForm extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddTaskForm({
    required Key key, // Ensure key is properly required and passed
    required this.firstName,
    required this.lastName,
    required this.email,
  }) : super(key: key);

  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  late String _taskOwner;
  String _subject = '';
  String _dueDate = '';
  String _contact = '';
  String _account = '';
  String _status = 'Not Started'; // Setting default status value
  String _priority = 'Normal'; // Setting default priority value
  bool _sendNotificationEmail = false;
  String _remainder = '';
  String _repeat = 'None'; // Setting default repeat value
  String _description = '';
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _taskOwner = '${widget.firstName} ${widget.lastName}';
  }
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = _dateFormat.format(pickedDate); // Format the selected date
      });
    }
  }
  Future<void> _handleSaveTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final taskData = {
        'task_owner': _taskOwner,
        'subject': _subject,
        'due_date': _dueDate,
        'contact': _contact,
        'account': _account,
        'status': _status,
        'priority': _priority,
        'remainder': _remainder,
        'repeat': _repeat,
        'description': _description,
        'send_notification_email': _sendNotificationEmail ? '1' : '0',
      };

      await _saveTask(taskData);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TASK INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee))),
          SizedBox(height: 10),
          buildDropdownField('Task Owner', [_taskOwner], Icons.person, _taskOwner, (newValue) {
            setState(() {
              _taskOwner = newValue!;
            });
          }, isRequired: true),
          buildTextField('Subject', Icons.subject, isRequired: true, onChanged: (value) => _subject = value),
          buildDatePickerField(
            'Due Date',
            Icons.calendar_today,
            onTap: () => _selectDueDate(context),
            value: _dueDate,
          ),
          buildTextField('Contact', Icons.contact_page, onChanged: (value) => _contact = value),
          buildTextField('Account', Icons.account_box, onChanged: (value) => _account = value),
          buildDropdownField('Status', [
            'Not Started',
            'Deferred',
            'In Progress',
            'Completed',
            'Waiting for input'
          ], Icons.stacked_bar_chart, _status, (newValue) {
            setState(() {
              _status = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Priority', [
            'High',
            'Highest',
            'Low',
            'Lowest',
            'Normal'
          ], Icons.low_priority, _priority, (newValue) {
            setState(() {
              _priority = newValue!;
            });
          }, isRequired: true),
          buildSwitchField('Send Notification Email'),
          buildTextField('Remainder', Icons.alarm, onChanged: (value) => _remainder = value),
          buildDropdownField('Repeat', ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'], Icons.repeat, _repeat, (newValue) {
            setState(() {
              _repeat = newValue!;
            });
          }),
          Text('DESCRIPTION INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee))),
          SizedBox(height: 10),
          buildTextField('Description', Icons.description, maxLines: 3, onChanged: (value) => _description = value),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSaveTask,
            child: Text('Save Task', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7b68ee), alignment: Alignment.center),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, {bool isRequired = false, int maxLines = 1, required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(color: Color(0xFF7b68ee)),
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Color(0xFF7b68ee)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7b68ee))),
        ),
        maxLines: maxLines,
        onChanged: onChanged,
        validator: isRequired ? (value) => value == null || value.isEmpty ? '$label is required' : null : null,
      ),
    );
  }

  Widget buildDropdownField(String label, List<String> items, IconData icon, String currentValue, ValueChanged<String?> onChanged, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(color: Color(0xFF7b68ee)),
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Color(0xFF7b68ee)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7b68ee))),
          errorText: isRequired && currentValue == 'None' ? '$label is required' : null,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            onChanged: onChanged,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Color(0xFF7b68ee))),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildDatePickerField(
      String label,
      IconData icon, {
        required VoidCallback onTap,
        required String value,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Color(0xFF7b68ee)),
            border: OutlineInputBorder(),
            prefixIcon: Icon(icon, color: Color(0xFF7b68ee)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF7b68ee)),
            ),
          ),
          controller: TextEditingController(text: value),
        ),
      ),
    );
  }

  Widget buildSwitchField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Color(0xFF7b68ee))),
          Switch(
            value: _sendNotificationEmail,
            onChanged: (newValue) {
              setState(() {
                _sendNotificationEmail = newValue;
              });
            },
            activeColor: Color(0xFF7b68ee),
          ),
        ],
      ),
    );
  }

  void submitForm() {
    _handleSaveTask();
  }
}