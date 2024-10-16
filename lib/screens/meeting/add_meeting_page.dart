import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../accounts/account_page.dart';
import '../contacts/contact_page.dart';

Future<void> _saveMeeting(Map<String, dynamic> meetingData) async {
  final response = await http.post(
    Uri.parse(saveMeetingUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(meetingData),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save lead');
  }
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
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _repeat = 'None';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _host = '${widget.firstName} ${widget.lastName}';
  }

  @override
  void dispose() {
    _accountController.dispose();
    _contactController.dispose();// Dispose the controller to avoid memory leaks
    super.dispose();
  }

  Future<void> _handleSaveMeeting() async {
    if (_formKey.currentState?.validate() ?? false) {
      final meetingData = {
        'host': _host,
        'title': _title,
        'location': _location,
        'to': _to,
        'contact': _contactController.text,
        'account': _accountController.text,
        'from': _from,
        'participants': _participants,
        'reminder': _reminder,
        'repeat': _repeat,
        'description': _description,
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

  Future<void> _selectDateTime(BuildContext context, String field) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);

        setState(() {
          if (field == 'from') {
            _from = formattedDateTime;
          } else if (field == 'to') {
            _to = formattedDateTime;
          }
        });
      }
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
          buildDateTimeField('From', 'from'),
          buildDateTimeField('To', 'to'),
          buildDropdownField('Host', [_host], Icons.person, _host, (newValue) {
            setState(() {
              _host = newValue!;
            });
          }, isRequired: true),

          buildTextField('Participants', Icons.people, onChanged: (value) => _participants = value),
          buildTextField(
            'Contact',
            Icons.contact_page,
            controller: _contactController, // Attach the controller here
            isRequired: true,
            onTap: () async {
              // Navigate to AccountPage and wait for a selected account
              final selectedContact = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                    forSelection: true,
                  ),
                ),
              );

              // If an contact is selected, update the _accountAccountController text field
              if (selectedContact != null) {
                setState(() {
                  _contactController.text = "${selectedContact['first_name']} ${selectedContact['last_name']}";
                });
              }
            },
          ),
          buildTextField(
            'Account',
            Icons.account_box,
            controller: _accountController, // Attach the controller here
            isRequired: true,
            onTap: () async {
              // Navigate to AccountPage and wait for a selected account
              final selectedAccount = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                    forSelection: true,
                  ),
                ),
              );

              // If an account is selected, update the _accountNameController text field
              if (selectedAccount != null) {
                setState(() {
                  _accountController.text = "${selectedAccount['first_name']} ${selectedAccount['last_name']}";
                });
              }
            },
          ),
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

  Widget buildTextField(
      String label,
      IconData icon, {
        TextEditingController? controller, // Controller is now optional
        bool isRequired = false,
        int maxLines = 1,
        ValueChanged<String>? onChanged, // Make onChanged optional
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap, // If onTap is provided, it will be called
      child: AbsorbPointer(
        absorbing: onTap != null, // Prevent keyboard input if onTap is provided
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: controller, // Use the controller if provided
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
            onChanged: controller == null
                ? onChanged // Use onChanged only if no controller is set
                : null,
            validator: isRequired
                ? (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            }
                : null,
          ),
        ),
      ),
    );
  }

  Widget buildDateTimeField(String label, String field, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _selectDateTime(context, field),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: isRequired ? '$label *' : label,
              labelStyle: TextStyle(color: Color(0xFF7b68ee)),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF7b68ee)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF7b68ee)),
              ),
            ),
            controller: TextEditingController(
              text: field == 'from' ? _from : _to,
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return '$label is required';
              }
              return null;
            },
          ),
        ),
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