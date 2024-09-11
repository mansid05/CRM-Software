import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveAccount(Map<String, dynamic> account) async {
  final prefs = await SharedPreferences.getInstance();
  final accountsJson = prefs.getStringList('accounts') ?? [];
  accountsJson.add(json.encode(account));
  await prefs.setStringList('accounts', accountsJson);
}

class AddAccountPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddAccountPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final addAccountFormKey = GlobalKey<_AddAccountFormState>(); // New key

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            onPressed: () {
              addAccountFormKey.currentState?.submitForm(); // Access form's submit
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddAccountForm(
            key: addAccountFormKey, // Pass key to AddAccountForm
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      ),
    );
  }
}

class AddAccountForm extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddAccountForm({
    required Key key,  // Make sure the key is required
    required this.firstName,
    required this.lastName,
    required this.email,
  }) : super(key: key);

  @override
  _AddAccountFormState createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  late String _accountOwner;
  String _phone = '';
  String _accountName = 'None';
  String _ownership = 'None';
  String _industry = 'None';
  String _accountType = 'None';
  String _annualRevenue = '';
  String _skypeId = '';
  String _billingStreet = '';
  String _billingCity = '';
  String _billingState = '';
  String _billingZipCode = '';
  String _billingCountry = '';
  String _shippingStreet = '';
  String _shippingCity = '';
  String _shippingState = '';
  String _shippingZipCode = '';
  String _shippingCountry = '';
  String _accountNumber = '';
  String _rating = 'None';
  String _description = '';
  String _employees = '';

  @override
  void initState() {
    super.initState();
    _accountOwner = '${widget.firstName} ${widget.lastName}';
  }

  Future<void> _handleSaveAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      final accountData = {
        'account_owner': _accountOwner,
        'account_number': _accountNumber,
        'account_name': _accountName,
        'account_type': _accountType,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'email': widget.email,
        'phone': _phone,
        'account_type': _accountType,
        'ownership': _ownership,
        'industry': _industry,
        'annual_revenue': _annualRevenue,
        'skype_id': _skypeId,
        'billing_street': _billingStreet,
        'billing_city': _billingCity,
        'billing_state': _billingState,
        'billing_zip_code': _billingZipCode,
        'billing_country': _billingCountry,
        'shipping_street': _shippingStreet,
        'shipping_city': _shippingCity,
        'shipping_state': _shippingState,
        'shipping_zip_code': _shippingZipCode,
        'shipping_country': _shippingCountry,
        'shipping_rating': _rating,
        'description': _description,
        'employees': _employees,
      };

      await _saveAccount(accountData);

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
          // ACCOUNT INFORMATION Section
          Text(
            'ACCOUNT INFORMATION',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildDropdownField(
              'Account Owner', [_accountOwner], Icons.person, _accountOwner, (
              newValue) {
            setState(() {
              _accountOwner = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Rating', [
            'None',
            'Acquired',
            'Active',
            'Market Failed',
            'Project Cancelled',
            'Shut Down'
          ], Icons.star, _rating, (newValue) {
            setState(() {
              _rating = newValue!;
            });
          }),
          buildTextField('Account Name', Icons.account_box, isRequired: true,
              onChanged: (value) => _accountName = value),
          buildTextField('Phone', Icons.phone, isRequired: true, onChanged: (value) => _phone = value),
          buildTextField('Account Site', Icons.accessibility, onChanged: (value) {}),
          buildTextField('Fax', Icons.print, onChanged: (value) {}),
          buildTextField('Parent Account', Icons.account_box, onChanged: (value) {}),
          buildTextField('Website', Icons.web, onChanged: (value) {}),
          buildTextField('Account Number', Icons.numbers, isRequired: true, onChanged: (value) => _accountNumber = value),
          buildTextField('Ticker Symbol', Icons.email, onChanged: (value) {}),
          buildDropdownField('Account Type', ['None', 'Analyst', 'Competitor', 'Customer', 'Distributor', 'Integrator', 'Investor', 'Other', 'Partner', 'Press', 'Prospect', 'Reseller', 'Supplier', 'Vendor'], Icons.account_box, _accountType, (newValue) {
            setState(() {
              _accountType = newValue!;
            });
          }, isRequired: true),
          buildDropdownField(
              'Ownership', ['None', 'Other', 'Private', 'Public', 'Subsidiary'],
              Icons.manage_accounts, _ownership, (newValue) {
            setState(() {
              _ownership = newValue!;
            });
          },),
          buildDropdownField('Industry', [
            'None',
            'ASP (Application Service Provider)',
            'Data/Telecom OEM',
            'ERP (Enterprise Resource Planning)',
            'Government/Military',
            'Large Enterprise',
            'MSP (Management Service Provider)',
            'Network Equipment Enterprise',
            'Non-management ISV',
            'Optical Networking',
            'Service Provider',
            'Small/Medium Enterprise',
            'Storage Equipment',
            'Storage Service Provider',
            'Wireless Industry'
          ], Icons.business, _industry, (newValue) {
            setState(() {
              _industry = newValue!;
            });
          },),
          buildTextField('Employees', Icons.people, isRequired: true,
              onChanged: (value) => _employees = value),
          buildTextField('Annual Revenue', Icons.attach_money, isRequired: true,
              onChanged: (value) => _annualRevenue = value),
          buildTextField('SIC Code', Icons.code, onChanged: (value) {}),
          SizedBox(height: 20),

          // ADDRESS INFORMATION Section
          Divider(),
          Text('ADDRESS INFORMATION', style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF7b68ee))),
          SizedBox(height: 10),

          // Mailing Address Section
          Text('Billing Address', style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 10),
          buildTextField('Billing Street', Icons.location_on, isRequired: true,
              onChanged: (value) => _billingStreet = value),
          buildTextField('Billing City', Icons.location_city, isRequired: true,
              onChanged: (value) => _billingCity = value),
          buildTextField('Billing State', Icons.map, isRequired: true,
              onChanged: (value) => _billingState = value),
          buildTextField('Billing Zip', Icons.local_post_office, isRequired: true,
              onChanged: (value) => _billingZipCode = value),
          buildTextField('Billing Country', Icons.public, isRequired: true,
              onChanged: (value) => _billingCountry = value),

          // Other Address Section
          SizedBox(height: 20),
          Text('Shipping Address', style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 10),
          buildTextField('Shipping Street', Icons.location_on, isRequired: true,
              onChanged: (value) => _shippingStreet = value),
          buildTextField('Shipping City', Icons.location_city, isRequired: true,
              onChanged: (value) => _shippingCity = value),
          buildTextField('Shipping State', Icons.map, isRequired: true,
              onChanged: (value) => _shippingState = value),
          buildTextField('Shipping Zip', Icons.local_post_office, isRequired: true,
              onChanged: (value) => _shippingZipCode = value),
          buildTextField('Shipping Country', Icons.public, isRequired: true,
              onChanged: (value) => _shippingCountry = value),
          Divider(),

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
            onPressed: _handleSaveAccount,
            child: Text('Save Account', style: TextStyle(color: Colors.white)),
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

  Widget buildDropdownField(String label, List<String> items, IconData icon,
      String currentValue, ValueChanged<String?> onChanged,
      {bool isRequired = false}) {
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

  void submitForm() {
    _handleSaveAccount();
  }
}
