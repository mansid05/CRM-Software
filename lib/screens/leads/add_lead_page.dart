import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveLead(Map<String, dynamic> lead) async {
  final prefs = await SharedPreferences.getInstance();
  final leadsJson = prefs.getStringList('leads') ?? [];
  leadsJson.add(json.encode(lead));
  await prefs.setStringList('leads', leadsJson);
}

class AddLeadPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddLeadPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Add Lead', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddLeadForm(
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      ),
    );
  }
}

class AddLeadForm extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AddLeadForm({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _AddLeadFormState createState() => _AddLeadFormState();
}

class _AddLeadFormState extends State<AddLeadForm> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  late String _leadOwner;
  String _company = '';
  String _salutation = 'None';
  String _title = '';
  String _mobile = '';
  String _leadSource = 'None';
  String _leadStatus = 'None';
  String _industry = 'None';
  String _annualRevenue = '';
  String _skypeId = '';
  String _street = '';
  String _city = '';
  String _state = '';
  String _zipCode = '';
  String _country = '';
  String _description = '';
  bool _emailOptOut = false;
  String _rating = 'None'; // Added this line

  @override
  void initState() {
    super.initState();
    _leadOwner = '${widget.firstName} ${widget.lastName}';
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

  Future<void> _handleSaveLead() async {
    if (_formKey.currentState?.validate() ?? false) {
      final leadData = {
        'lead_owner': _leadOwner,
        'salutation': _salutation,
        'company': _company,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'title': _title,
        'email': widget.email,
        'mobile': _mobile,
        'lead_source': _leadSource,
        'lead_status': _leadStatus,
        'industry': _industry,
        'annual_revenue': _annualRevenue,
        'skype_id': _skypeId,
        'street': _street,
        'city': _city,
        'state': _state,
        'zip_code': _zipCode,
        'country': _country,
        'description': _description,
        'photo': _imageFile?.path ?? '',
        'email_opt_out': _emailOptOut ? '1' : '0',
        'rating': _rating, // Added this line
      };

      await _saveLead(leadData);

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
          // LEAD IMAGE Section
          Text(
            'LEAD IMAGE',
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

          // LEAD INFORMATION Section
          Text(
            'LEAD INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildDropdownField('Lead Owner', [_leadOwner], Icons.person, _leadOwner, (newValue) {
            setState(() {
              _leadOwner = newValue!;
            });
          }, isRequired: true),
          buildTextField('Company', Icons.business, isRequired: true, onChanged: (value) => _company = value),
          buildDropdownField('Salutation', ['None', 'Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Prof.'], Icons.person, _salutation, (newValue) {
            setState(() {
              _salutation = newValue!;
            });
          }),
          buildTextField('First Name', Icons.person, isRequired: true, onChanged: (value) {}),
          buildTextField('Last Name', Icons.person, isRequired: true, onChanged: (value) {}),
          buildTextField('Title', Icons.work, onChanged: (value) => _title = value),
          buildTextField('Email', Icons.email, isRequired: true, onChanged: (value) {}),
          buildTextField('Phone', Icons.phone, onChanged: (value) {}),
          buildTextField('Fax', Icons.print, onChanged: (value) {}),
          buildTextField('Mobile', Icons.smartphone, isRequired: true, onChanged: (value) => _mobile = value),
          buildTextField('Website', Icons.web, onChanged: (value) {}),
          buildDropdownField('Lead Source', ['None', 'Advertisement', 'Cold Call', 'Employee Referral', 'External Referral', 'Online Store', 'Public Relations', 'Internal Seminar', 'Trade Show', 'Web Download', 'Web Research', 'Chat', 'X (Twitter)', 'Facebook'], Icons.source, _leadSource, (newValue) {
            setState(() {
              _leadSource = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Lead Status', ['None', 'Attempted to Contact', 'Contact in Future', 'Contacted', 'Junk Lead', 'Lost Lead', 'Not Contacted', 'Pre-Qualified', 'Not Qualified'], Icons.flag, _leadStatus, (newValue) {
            setState(() {
              _leadStatus = newValue!;
            });
          }, isRequired: true),
          buildDropdownField('Industry', ['None', 'ASP (Application Service Provider)', 'Data/Telecom OEM', 'ERP (Enterprise Resource Planning)', 'Government/Military', 'Large Enterprise', 'MSP (Management Service Provider)', 'Network Equipment Enterprise', 'Non-management ISV', 'Optical Networking', 'Service Provider', 'Small/Medium Enterprise', 'Storage Equipment', 'Storage Service Provider', 'Wireless Industry'], Icons.business, _industry, (newValue) {
            setState(() {
              _industry = newValue!;
            });
          }, isRequired: true),
          buildTextField('No. of Employees', Icons.people, onChanged: (value) {}),
          buildTextField('Annual Revenue', Icons.attach_money, isRequired: true, onChanged: (value) => _annualRevenue = value),
          buildDropdownField('Rating', ['None', 'Acquired', 'Active', 'Market Failed', 'Project Cancelled', 'Shut Down'], Icons.star, _rating, (newValue) {
            setState(() {
              _rating = newValue!;
            });
          }),
          buildSwitchField('Email Opt Out'),
          buildTextField('Skype ID', Icons.video_call, isRequired: true, onChanged: (value) => _skypeId = value),
          buildTextField('Secondary Email', Icons.alternate_email, onChanged: (value) {}),
          buildTextField('Twitter', Icons.alternate_email, onChanged: (value) {}),
          SizedBox(height: 20),

          // ADDRESS INFORMATION Section
          Text(
            'ADDRESS INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Street', Icons.location_on, isRequired: true, onChanged: (value) => _street = value),
          buildTextField('City', Icons.location_city, isRequired: true, onChanged: (value) => _city = value),
          buildTextField('State', Icons.map, isRequired: true, onChanged: (value) => _state = value),
          buildTextField('Zip Code', Icons.local_post_office, isRequired: true, onChanged: (value) => _zipCode = value),
          buildTextField('Country', Icons.public, isRequired: true, onChanged: (value) => _country = value),
          SizedBox(height: 20),

          // DESCRIPTION INFORMATION Section
          Text(
            'DESCRIPTION INFORMATION',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7b68ee)),
          ),
          SizedBox(height: 10),
          buildTextField('Description', Icons.description, maxLines: 3, onChanged: (value) => _description = value),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSaveLead,
            child: Text('Save Lead', style: TextStyle(color: Colors.white)),
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
}
