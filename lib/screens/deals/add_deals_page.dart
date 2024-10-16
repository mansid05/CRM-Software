import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../accounts/account_page.dart';
import '../contacts/contact_page.dart';

Future<void> _saveDeal(Map<String, dynamic> dealData) async {
  final response = await http.post(
    Uri.parse(saveDealUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(dealData),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to save deal');
  }
}

class AddDealPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddDealPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final addDealFormKey = GlobalKey<_AddDealFormState>(); // New key

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Deal', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            onPressed: () {
              addDealFormKey.currentState?.submitForm(); // Access form's submit
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddDealForm(
            key: addDealFormKey, // Pass key to AddDealForm
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      ),
    );
  }
}

class AddDealForm extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddDealForm({
    required Key key,
    required this.firstName,
    required this.lastName,
    required this.email,
  }) : super(key: key);

  @override
  _AddDealFormState createState() => _AddDealFormState();
}

class _AddDealFormState extends State<AddDealForm> {
  final _formKey = GlobalKey<FormState>();
  late String _dealOwner;
  String _dealName = '';
  final TextEditingController _accountNameController = TextEditingController();
  String _closingDate = '';
  String _amount = '';
  String _stage = '';
  String _type = '';
  String _leadSource = '';
  String _expectedRevenue = '';
  final TextEditingController _contactNameController = TextEditingController();
  String _campaignSource = '';
  String _description = '';
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _dealOwner = '${widget.firstName} ${widget.lastName}';
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _contactNameController.dispose();// Dispose the controller to avoid memory leaks
    super.dispose();
  }


  Future<void> _selectClosingDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _closingDate = _dateFormat.format(pickedDate); // Format the selected date
      });
    }
  }

  Future<void> _handleSaveDeal() async {
    if (_formKey.currentState?.validate() ?? false) {
      final dealData = {
        'deal_owner': _dealOwner,
        'amount': _amount,
        'deal_name': _dealName,
        'closing_date': _closingDate,
        'account_name': _accountNameController.text,
        'type': _type,
        'stage': _stage,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'expected_revenue': _expectedRevenue,
        'lead_source': _leadSource,
        'contact_name': _accountNameController.text,
        'campaign_source': _campaignSource,
        'description': _description,
      };

      try {
        await _saveDeal(dealData);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save deal: $e')),
        );
      }
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
          // DEALS INFORMATION Section
          Text(
            'DEALS INFORMATION',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildDropdownField(
            'Deal Owner',
            [_dealOwner],
            Icons.person,
            _dealOwner,
                (newValue) {
              setState(() {
                _dealOwner = newValue!;
              });
            },
            isRequired: true,
          ),
          buildTextField('Amount', Icons.attach_money,
              onChanged: (value) => _amount = value),
          buildTextField('Deal Name', Icons.monetization_on,
              isRequired: true, onChanged: (value) => _dealName = value),
          buildDatePickerField(
            'Closing Date',
            Icons.calendar_today,
            onTap: () => _selectClosingDate(context),
            value: _closingDate,
          ),
          buildTextField(
            'Account Name',
            Icons.account_box,
            controller: _accountNameController, // Attach the controller here
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
                  _accountNameController.text = "${selectedAccount['first_name']} ${selectedAccount['last_name']}";
                });
              }
            },
          ),
          buildDropdownField(
            'Stage',
            [
              'Qualification',
              'Need Analysis',
              'Value Proposition',
              'Identify Decision Makers',
              'Proposal/Price Quote',
              'Negotiation/Review',
              'Closed Won',
              'Closed Lost',
              'Closed Lost to Competition'
            ],
            Icons.stacked_bar_chart,
            _stage,
                (newValue) {
              setState(() {
                _stage = newValue!;
              });
            },
            isRequired: true,
          ),
          buildDropdownField(
            'Type',
            ['None', 'Existing Business', 'New Business'],
            Icons.difference,
            _type,
                (newValue) {
              setState(() {
                _type = newValue!;
              });
            },
            isRequired: true,
          ),
          buildTextField('Next Step', Icons.stacked_bar_chart,
              onChanged: (value) {}),
          buildTextField('Probability(%)', Icons.superscript,
              onChanged: (value) {}),
          buildDropdownField(
            'Lead Source',
            [
              'None',
              'Advertisement',
              'Cold Call',
              'Employee Referral',
              'External Referral',
              'Online Store',
              'Public Relations',
              'Internal Seminar',
              'Trade Show',
              'Web Download',
              'Web Research',
              'Chat',
              'X (Twitter)',
              'Facebook'
            ],
            Icons.source,
            _leadSource,
                (newValue) {
              setState(() {
                _leadSource = newValue!;
              });
            },
          ),
          buildTextField('Expected Revenue', Icons.attach_money,
              onChanged: (value) => _expectedRevenue = value),
          buildTextField(
            'Contact Name',
            Icons.contact_page,
            controller: _contactNameController, // Attach the controller here
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
                  _contactNameController.text = "${selectedContact['first_name']} ${selectedContact['last_name']}";
                });
              }
            },
          ),
          buildTextField('Campaign Source', Icons.campaign,
              onChanged: (value) => _campaignSource = value),

          // DESCRIPTION INFORMATION Section
          Text(
            'DESCRIPTION INFORMATION',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Description', Icons.description,
              maxLines: 3, onChanged: (value) => _description = value),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSaveDeal,
            child: Text('Save Deal', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7b68ee),
                alignment: Alignment.center),
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


  Widget buildDatePickerField(
      String label,
      IconData icon, {
        required VoidCallback onTap,
        required String value,
        bool isRequired = true,
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

  Widget buildDropdownField(
      String label,
      List<String> items,
      IconData icon,
      String currentValue,
      ValueChanged<String?> onChanged, {
        bool isRequired = false,
      }) {
    final validValue =
    items.contains(currentValue) ? currentValue : items.isNotEmpty ? items.first : null;

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
          errorText: isRequired && validValue == null
              ? '$label is required'
              : null,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: validValue,
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

  void submitForm() {
    _handleSaveDeal();
  }
}