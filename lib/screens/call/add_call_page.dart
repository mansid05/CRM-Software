import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to save the call data
Future<void> _saveCall(Map<String, dynamic> call) async {
  final prefs = await SharedPreferences.getInstance();
  final callsJson = prefs.getStringList('calls') ?? [];
  callsJson.add(json.encode(call));
  await prefs.setStringList('calls', callsJson);
}

class AddCallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Key for the form
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
      // Adding the form as part of the page body
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

  // Variables for form fields
  String _contact = '';
  String _account = '';
  String _callType = 'Outbound';
  String _outgoingCallStatus = 'None';
  String _callStartTime = '';
  String _callDuration = '';
  String _subject = '';
  String _callPurpose = 'None';
  String _callAgenda = '';
  String _callResult = 'None';
  String _description = '';

  // Function to handle saving the call
  Future<void> _handleSaveCall() async {
    if (_formKey.currentState?.validate() ?? false) {
      final callData = {
        'contact': _contact,
        'account': _account,
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
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // CALL INFORMATION Section
          Text(
            'CALL INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Contact', Icons.contact_page, isRequired: true, onChanged: (value) => _contact = value),
          buildTextField('Account', Icons.account_box, isRequired: true, onChanged: (value) => _account = value),
          buildDropdownField('Call Type', ['Outbound', 'Inbound', 'Missed'], Icons.call_made, _callType, (newValue) {
            setState(() {
              _callType = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Outgoing Call Status', ['None', 'Completed', 'Scheduled'], Icons.call_missed_outgoing, _outgoingCallStatus, (newValue) {
            setState(() {
              _outgoingCallStatus = newValue!;
            });
          }),
          buildTextField('Call Start Time', Icons.calendar_month, isRequired: true, onChanged: (value) => _callStartTime = value),
          buildTextField('Call Duration', Icons.timelapse, isRequired: true, onChanged: (value) => _callDuration = value),
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

  // Method to submit the form
  void submitForm() {
    _handleSaveCall();
  }
}
