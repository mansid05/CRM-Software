import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveContact(Map<String, dynamic> contact) async {
  final prefs = await SharedPreferences.getInstance();
  final contactsJson = prefs.getStringList('contacts') ?? [];
  contactsJson.add(json.encode(contact));
  await prefs.setStringList('contacts', contactsJson);
}

class AddContactPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddContactPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final addContactFormKey = GlobalKey<_AddContactFormState>(); // New key

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Contact', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            onPressed: () {
              addContactFormKey.currentState?.submitForm(); // Access form's submit
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddContactForm(
            key: addContactFormKey, // Pass key to AddAccountForm
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      ),
    );
  }
}

class AddContactForm extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddContactForm({
    required Key key,  // Make sure the key is required
    required this.firstName,
    required this.lastName,
    required this.email,
  }) : super(key: key);

  @override
  _AddContactFormState createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  late String _contactOwner;
  String _leadSource = 'None';
  String _salutation = 'None';
  String _title = '';
  String _department = '';
  String _mobile = '';
  String _skypeId = '';
  String _mailingStreet = '';
  String _mailingCity = '';
  String _mailingState = '';
  String _mailingZipCode = '';
  String _mailingCountry = '';
  String _street = '';
  String _city = '';
  String _state = '';
  String _zipCode = '';
  String _country = '';
  String _description = '';
  String _accountName = '';
  String _vendorName = '';
  String _dateOfBirth = '';
  String _reportingTo = '';
  bool _emailOptOut = false;

  @override
  void initState() {
    super.initState();
    _contactOwner = '${widget.firstName} ${widget.lastName}';
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _handleSaveContact() async {
    if (_formKey.currentState?.validate() ?? false) {
      final contactData = {
        'contact_owner': _contactOwner,
        'lead_source': _leadSource,
        'salutation': _salutation,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'account_name': _accountName,
        'vendor_name': _vendorName,
        'title': _title,
        'email': widget.email,
        'department': _department,
        'mobile': _mobile,
        'date_of_birth': _dateOfBirth,
        'skype_id': _skypeId,
        'mailing_street': _mailingStreet,
        'mailing_city': _mailingCity,
        'mailing_state': _mailingState,
        'mailing_zip_code': _mailingZipCode,
        'mailing_country': _mailingCountry,
        'street': _street,
        'city': _city,
        'state': _state,
        'zip_code': _zipCode,
        'country': _country,
        'description': _description,
        'photo': _imageFile?.path ?? '',
        'email_opt_out': _emailOptOut ? '1' : '0',
      };

      await _saveContact(contactData);

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
          // CONTACT IMAGE Section
          Text(
            'CONTACT IMAGE',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              _showPhotoOptions(context);
            },
            child: buildPhotoUploadSection(),
          ),
          SizedBox(height: 20),

          // CONTACT INFORMATION Section
          Text(
            'CONTACT INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildDropdownField('Contact Owner', [_contactOwner], Icons.person, _contactOwner, (newValue) {
            setState(() {
              _contactOwner = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Lead Source', ['None', 'Advertisement', 'Cold Call', 'Employee Referral', 'External Referral', 'Online Store', 'Public Relations', 'Internal Seminar', 'Trade Show', 'Web Download', 'Web Research', 'Chat', 'X (Twitter)', 'Facebook'], Icons.source, _leadSource, (newValue) {
            setState(() {
              _leadSource = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Salutation', ['None', 'Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Prof.'], Icons.person, _salutation, (newValue) {
            setState(() {
              _salutation = newValue!;
            });
          }),
          buildTextField('First Name', Icons.person, isRequired: true, onChanged: (value) {}),
          buildTextField('Last Name', Icons.person, isRequired: true, onChanged: (value) {}),
          buildTextField('Account Name', Icons.business, onChanged: (value) => _accountName = value),
          buildTextField('Vendor Name', Icons.business, isRequired: true,onChanged: (value) => _vendorName = value),
          buildTextField('Title', Icons.work, onChanged: (value) => _title = value),
          buildTextField('Email', Icons.email, isRequired: true, onChanged: (value) {}),
          buildTextField('Department', Icons.account_balance, isRequired: true, onChanged: (value) => _department = value),
          buildTextField('Phone', Icons.phone, onChanged: (value) {}),
          buildTextField('Home Phone', Icons.phone, onChanged: (value) {}),
          buildTextField('Other Phone', Icons.phone, onChanged: (value) {}),
          buildTextField('Fax', Icons.print, onChanged: (value) {}),
          buildTextField('Mobile', Icons.smartphone, isRequired: true, onChanged: (value) => _mobile = value),
          buildTextField('Date of Birth', Icons.cake, onChanged: (value) => _dateOfBirth = value),
          buildTextField('Assistant', Icons.person_add, onChanged: (value) {}),
          buildTextField('Asst Phone', Icons.phone_android, onChanged: (value) {}),
          buildSwitchField('Email Opt Out'),
          buildTextField('Skype ID', Icons.video_call, onChanged: (value) => _skypeId = value),
          buildTextField('Secondary Email', Icons.alternate_email, onChanged: (value) {}),
          buildTextField('Twitter', Icons.alternate_email, onChanged: (value) {}),
          buildTextField('Reporting to', Icons.supervisor_account, onChanged: (value) => _reportingTo = value),
          SizedBox(height: 20),

          // ADDRESS INFORMATION Section
          Divider(),
          Text('ADDRESS INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee))),
          SizedBox(height: 10),

          // Mailing Address Section
          Text('Mailing Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 10),
          buildTextField('Mailing Street', Icons.location_on, onChanged: (value) => _mailingStreet = value),
          buildTextField('Mailing City', Icons.location_city, onChanged: (value) => _mailingCity = value),
          buildTextField('Mailing State', Icons.map, onChanged: (value) => _mailingState = value),
          buildTextField('Mailing Zip', Icons.local_post_office, onChanged: (value) => _mailingZipCode = value),
          buildTextField('Mailing Country', Icons.public, onChanged: (value) => _mailingCountry = value),

          // Other Address Section
          SizedBox(height: 20),
          Text('Other Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 10),
          buildTextField('Other Street', Icons.location_on, onChanged: (value) => _street = value),
          buildTextField('Other City', Icons.location_city, onChanged: (value) => _city = value),
          buildTextField('Other State', Icons.map, onChanged: (value) => _state = value),
          buildTextField('Other Zip', Icons.local_post_office, onChanged: (value) => _zipCode = value),
          buildTextField('Other Country', Icons.public, onChanged: (value) => _country = value),
          Divider(),

          // DESCRIPTION INFORMATION Section
          Text(
            'DESCRIPTION INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Description', Icons.description, maxLines: 3, onChanged: (value) => _description = value),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSaveContact,
            child: Text('Save Contact', style: TextStyle(color: Colors.white)),
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
            value: _emailOptOut,
            onChanged: (newValue) {
              setState(() {
                _emailOptOut = newValue;
              });
            },
            activeColor: Color(0xFF7b68ee),
          ),
        ],
      ),
    );
  }

  Widget buildPhotoUploadSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF7b68ee)),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('Photo', style: TextStyle(color: Color(0xFF7b68ee))),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                _imageFile!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          else
            Row(
              children: [
                Icon(Icons.camera_alt, color: Color(0xFF7b68ee)),
                SizedBox(width: 5),
                Icon(Icons.photo_library, color: Color(0xFF7b68ee)),
              ],
            ),
        ],
      ),
    );
  }
  void submitForm() {
    _handleSaveContact();
  }
}
