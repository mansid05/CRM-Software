import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../accounts/account_page.dart';
import '../contacts/contact_page.dart';

Future<void> _saveCall(Map<String, dynamic> callData) async {
  final response = await http.post(
    Uri.parse(saveCallUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(callData),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save lead');
  }
}

class AddCallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final addCallFormKey = GlobalKey<_AddCallFormState>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Call', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            onPressed: () {
              addCallFormKey.currentState?.submitForm();
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: AddCallForm(key: addCallFormKey),
    );
  }
}

class AddCallForm extends StatefulWidget {
  const AddCallForm({Key? key}) : super(key: key);

  @override
  _AddCallFormState createState() => _AddCallFormState();
}

class _AddCallFormState extends State<AddCallForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _callType = 'Outbound';
  String _outgoingCallStatus = 'Completed';
  String _callStartTime = '';
  String _callDuration = '';
  String _subject = '';
  String _callPurpose = 'None';
  String _callAgenda = '';
  String _callResult = 'None';
  String _description = '';

  @override
  void dispose() {
    _accountController.dispose();
    _contactController.dispose();// Dispose the controller to avoid memory leaks
    super.dispose();
  }

  Future<void> _handleSaveCall() async {
    if (_formKey.currentState?.validate() ?? false) {
      final callData = {
        'contact': _contactController.text,
        'account': _accountController.text,
        'call_type': _callType,
        'outgoing_call_status': _outgoingCallStatus,
        'call_start_time': _callStartTime,
        'call_duration': _callDuration,
        'subject': _subject,
        'call_purpose': _callPurpose,
        'call_agenda': _callAgenda,
        'call_result': _callResult,
        'description': _description,
      };
      await _saveCall(callData);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Wrap with Form widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CALL INFORMATION Section
              Text(
                'CALL INFORMATION',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
              ),
              SizedBox(height: 10),
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
                        forSelection: true, firstName: '', lastName: '', email: ' ',
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
                        forSelection: true, firstName: '', lastName: '', email: '',
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
              buildDropdownField('Call Type', ['Outbound', 'Inbound', 'Missed'], Icons.call_made, _callType, (newValue) {
                setState(() {
                  _callType = newValue!;
                });
              }, isRequired: true),
              buildDropdownField('Outgoing Call Status', ['Completed', 'Scheduled'], Icons.call_missed_outgoing, _outgoingCallStatus, (newValue) {
                setState(() {
                  _outgoingCallStatus = newValue!;
                });
              }),
              buildTextField('Call Start Time', Icons.calendar_month, isRequired: true, onChanged: (value) => _callStartTime = value),
              buildDurationField(),
              buildTextField('Subject', Icons.subject, onChanged: (value) => _subject = value),

              // PURPOSE Section
              Text(
                'PURPOSE OF OUTGOING CALL',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
              ),
              SizedBox(height: 10),
              buildDropdownField('Call Purpose', ['None', 'Prospecting', 'Administrative', 'Negotiation', 'Demo', 'Project', 'Desk'], Icons.call_rounded, _callPurpose, (newValue) {
                setState(() {
                  _callPurpose = newValue!;
                });
              }, isRequired: true),
              buildTextField('Call Agenda', Icons.view_agenda, onChanged: (value) => _callAgenda = value),

              // OUTCOME Section
              Text(
                'OUTCOME OF OUTGOING CALL',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
              ),
              SizedBox(height: 10),
              buildDropdownField('Call Result', ['None', 'Interested', 'Not Interested', 'No response/Busy', 'Requested more info', 'Requested call back', 'Invalid Number'], Icons.call, _callResult, (newValue) {
                setState(() {
                  _callResult = newValue!;
                });
              }, isRequired: true),
              buildTextField('Description', Icons.description, maxLines: 3, onChanged: (value) => _description = value),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSaveCall,
                child: Text('Save Call', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7b68ee),
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ),
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
    // Special case for "Call Start Time"
    if (label == 'Call Start Time') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () async {
            // Open the date picker
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (selectedDate != null) {
              // Open the time picker
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime != null) {
                // Combine date and time
                DateTime combinedDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                // Format the combined date and time
                String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);

                // Update the callStartTime variable and call onChanged callback
                setState(() {
                  _callStartTime = formattedDateTime;
                  if (onChanged != null) {
                    onChanged(_callStartTime); // Notify about the change
                  }
                });
              }
            }
          },
          child: AbsorbPointer(
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
              controller: TextEditingController(text: _callStartTime), // Display the selected date/time
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

    // General TextFormField for all other fields
    return GestureDetector(
      onTap: onTap, // Handle onTap event if provided
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
            onChanged: controller == null ? onChanged : null, // Use onChanged only if no controller is set
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


  Widget buildDurationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (selectedTime != null) {
            // Format the selected time
            String formattedDuration = selectedTime.format(context);
            setState(() {
              _callDuration = formattedDuration;
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Call Duration',
              labelStyle: TextStyle(color: Color(0xFF7b68ee)),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timelapse, color: Color(0xFF7b68ee)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF7b68ee)),
              ),
            ),
            controller: TextEditingController(text: _callDuration), // Display the selected duration
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Call Duration is required';
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

  // Method to submit the form
  void submitForm() {
    _handleSaveCall();
  }
}
