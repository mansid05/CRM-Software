import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveDeals(Map<String, dynamic> deal) async {
  final prefs = await SharedPreferences.getInstance();
  final dealsJson = prefs.getStringList('deals') ?? [];
  dealsJson.add(json.encode(deal));
  await prefs.setStringList('deals', dealsJson);
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
    required Key key,  // Make sure the key is required
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
  String _dealName = 'None';
  String _accountName = 'None';
  String _closingDate = '';
  String _amount = '';
  String _stage = '';
  String _type = 'None';
  String _leadSource = '';
  String _expectedRevenue = '';
  String _contactName = '';
  String _campaignSource = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _dealOwner = '${widget.firstName} ${widget.lastName}';
  }

  Future<void> _handleSaveDeal() async {
    if (_formKey.currentState?.validate() ?? false) {
      final dealData = {
        'deal_owner': _dealOwner,
        'amount': _amount,
        'deal_name': _dealName,
        'closing_date': _closingDate,
        'account_name': _accountName,
        'type': _type,
        'stage': _stage,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'expected_revenue': _expectedRevenue,
        'lead_source': _leadSource,
        'contact_name': _contactName,
        'campaign_source': _campaignSource,
        'description': _description,
      };

      await _saveDeals(dealData);

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
          // DEALS INFORMATION Section
          Text(
            'DEALS INFORMATION',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildDropdownField(
              'Deal Owner', [_dealOwner], Icons.person, _dealOwner, (
              newValue) {
            setState(() {
              _dealOwner = newValue!;
            });
          }, isRequired: true),
          buildTextField('Amount', Icons.attach_money, onChanged: (value) => _amount = value),
          buildTextField('Deal Name', Icons.monetization_on, isRequired: true,
              onChanged: (value) => _dealName = value),
          buildTextField('Closing Date', Icons.calendar_month, isRequired: true,
              onChanged: (value) => _closingDate = value),
          buildTextField('Account Name', Icons.account_box, isRequired: true,
              onChanged: (value) => _accountName = value),
          buildDropdownField('Stage', ['Qualification', 'Need Analysis', 'Value Proposition', 'Identify Decision Makers', 'Proposal/PriceQuote', 'Negotiation/Review', 'Closed Won', 'Closed Lost', 'Closed Lost to Competition'], Icons.stacked_bar_chart, _stage, (newValue) {
            setState(() {
              _stage = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Type', ['None', 'Existing Business', 'New Business'], Icons.difference, _type, (newValue) {
            setState(() {
              _type = newValue!;
            });
          }, isRequired: true),
          buildTextField('Next Step', Icons.stacked_bar_chart, onChanged: (value) {}),
          buildTextField('Probability(%)', Icons.superscript, onChanged: (value) {}),
          buildDropdownField('Lead Source', ['None', 'Advertisement', 'Cold Call', 'Employee Referral', 'External Referral', 'Online Store', 'Public Relations', 'Internal Seminar', 'Trade Show', 'Web Download', 'Web Research', 'Chat', 'X (Twitter)', 'Facebook'], Icons.source, _leadSource, (newValue) {
            setState(() {
              _leadSource = newValue!;
            });
          },),
          buildTextField('Expected Revenue', Icons.attach_money, onChanged: (value) => _expectedRevenue = value),
          buildTextField('Contact Name', Icons.contact_page, onChanged: (value) => _contactName = value),
          buildTextField('Campaign Source', Icons.campaign, onChanged: (value) => _campaignSource = value),

          // DESCRIPTION INFORMATION Section
          Text(
            'DESCRIPTION INFORMATION',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Description', Icons.description, maxLines: 3,
              onChanged: (value) => _description = value),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSaveDeal,
            child: Text('Save Deal', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7b68ee),
                alignment: Alignment.center
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, IconData icon,
      {bool isRequired = false, int maxLines = 1, required ValueChanged<
          String> onChanged}) {
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

  Widget buildDropdownField(
      String label,
      List<String> items,
      IconData icon,
      String currentValue,
      ValueChanged<String?> onChanged, {
        bool isRequired = false,
      }) {
    // Ensure currentValue is valid
    final validValue = items.contains(currentValue) ? currentValue : items.isNotEmpty ? items.first : null;

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
