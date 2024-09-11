import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveMeeting(Map<String, dynamic> meeting) async {
  final prefs = await SharedPreferences.getInstance();
  final meetingsJson = prefs.getStringList('meetings') ?? [];
  meetingsJson.add(json.encode(meeting));
  await prefs.setStringList('meetings', meetingsJson);
}

class AddMeetingPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddMeetingPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final addMeetingFormKey = GlobalKey<_AddMeetingFormState>(); // New key

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Meeting', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            onPressed: () {
              addMeetingFormKey.currentState?.submitForm(); // Access form's submit
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddMeetingForm(
            key: addMeetingFormKey, // Pass key to AddMeetingForm
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      ),
    );
  }
}

class AddMeetingForm extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddMeetingForm({
    required Key key,  // Make sure the key is required
    required this.firstName,
    required this.lastName,
    required this.email,
  }) : super(key: key);

  @override
  _AddMeetingFormState createState() => _AddMeetingFormState();
}

class _AddMeetingFormState extends State<AddMeetingForm> {
  final _formKey = GlobalKey<FormState>();
  late String _host;
  String _title = '';
  String _location = '';
  String _from = '';
  String _to = '';
  String _participants = '';
  String _reminder = 'None';
  bool _allDay = false;
  String _account = '';
  String _repeat = 'None';
  String _description = '';
  String _contact = '';

  @override
  void initState() {
    super.initState();
    _host = '${widget.firstName} ${widget.lastName}';
  }

  Future<void> _handleSaveMeeting() async {
    if (_formKey.currentState?.validate() ?? false) {
      final meetingData = {
        'host': _host,
        'title': _title,
        'location': _location,
        'to': _to,
        'account': _account,
        'from': _from,
        'participants': _participants,
        'reminder': _reminder,
        'repeat': _repeat,
        'description': _description,
        'contact': _contact,
        'all_day': _allDay ? '1' : '0',
      };

      await _saveMeeting(meetingData);

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
          // MEETING INFORMATION Section
          Text(
            'MEETING INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Title', Icons.title, isRequired: true, onChanged: (value) => _title = value),
          buildTextField('Location', Icons.location_city, onChanged: (value) => _location = value),
          buildSwitchField('All Day'),
          buildTextField('From', Icons.calendar_month, isRequired: true, onChanged: (value) => _from = value),
          buildTextField('To', Icons.calendar_month, isRequired: true, onChanged: (value) => _to = value),
          buildDropdownField('Host', [_host], Icons.person, _host, (newValue) {
            setState(() {
              _host = newValue!;
            });
          }, isRequired: true),

          buildTextField('Participants', Icons.people, onChanged: (value) => _participants = value),
          buildTextField('Contact', Icons.contact_page, onChanged: (value) => _account = value),
          buildTextField('Account', Icons.account_box, onChanged: (value) => _account = value),
          buildDropdownField('Repeat', ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'], Icons.repeat, _repeat, (newValue) {
            setState(() {
              _repeat = newValue!;
            });
          },),



          // DESCRIPTION INFORMATION Section
          Text(
            'MEETING ADDTIONAL INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Description', Icons.description, maxLines: 3, onChanged: (value) => _description = value),
          buildDropdownField('Reminder', ['None', 'At the time of meeting', '5 minutes before', '10 minutes before', '15 minutes before', '30 minutes before', '1 hour before', '2 hours before', '1 day before', '2 days before'], Icons.alarm, _reminder, (newValue) {
            setState(() {
              _reminder = newValue!;
            });
          }, isRequired: true),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSaveMeeting,
            child: Text('Save Meeting', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7b68ee),
                alignment: Alignment.center
            ),
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
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF7b68ee)),
          ),
        ),
        maxLines: maxLines,
        onChanged: onChanged,
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        }
            : null,
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
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF7b68ee)),
          ),
          errorText: isRequired && currentValue == 'None'
              ? '$label is required'
              : null,
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

  Widget buildSwitchField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Color(0xFF7b68ee))),
          Switch(
            value: _allDay,
            onChanged: (newValue) {
              setState(() {
                _allDay = newValue;
              });
            },
            activeColor: Color(0xFF7b68ee),
          ),
        ],
      ),
    );
  }

  void submitForm() {
    _handleSaveMeeting();
  }
}
