import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_contact_page.dart';

class ContactPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  ContactPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('contacts') ?? [];
    setState(() {
      _contacts = contactsJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteContact(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('contacts') ?? [];
    contactsJson.removeAt(index); // Remove the contact from the list
    await prefs.setStringList('contacts', contactsJson); // Save updated list

    setState(() {
      _contacts.removeAt(index); // Update UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContactPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                  ),
                ),
              ).then((_) => _fetchContacts()); // Refresh contacts after adding a new one
            },
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Contacts',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchContacts,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${contact['contact_owner']}'),
                    subtitle: Text(contact['mobile'] ?? 'mobile'),
                    leading: contact['photo'] != null && contact['photo'].isNotEmpty
                        ? CircleAvatar(
                      backgroundImage: FileImage(File(contact['photo']!)),
                    )
                        : CircleAvatar(
                      child: Icon(Icons.person),
                      backgroundColor: Color(0xFF7b68ee),
                      foregroundColor: Colors.white,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailPage(contact: contact),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFF7b68ee)),
                  onPressed: () async {
                    final shouldDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Contact'),
                        content: Text('Are you sure you want to delete this contact?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete) {
                      _deleteContact(index);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final Map<String, dynamic> contact;

  ContactDetailPage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('${contact['first_name'] ?? 'Unknown'} ${contact['last_name'] ?? 'Unknown'}', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Account Name', contact['account_name'] ?? 'N/A'),
            _buildDetailRow('Vendor Name', contact['vendor_name'] ?? 'N/A'),
            _buildDetailRow('Title', contact['title'] ?? 'N/A'),
            _buildDetailRow('Email', contact['email'] ?? 'N/A'),
            _buildDetailRow('Mobile', contact['mobile'] ?? 'N/A'),
            _buildDetailRow('Phone', contact['phone'] ?? 'N/A'),
            _buildDetailRow('Department', contact['department'] ?? 'N/A'),
            _buildDetailRow('Date of Birth', contact['date_of_birth']?.toString() ?? 'N/A'),
            _buildDetailRow('Skype ID', contact['skype_id'] ?? 'N/A'),
            _buildDetailRow('Secondary Email', contact['secondary_email'] ?? 'N/A'),
            _buildDetailRow('Twitter', contact['twitter'] ?? 'N/A'),
            _buildDetailRow('Mailing Street', contact['mailing_street'] ?? 'N/A'),
            _buildDetailRow('Mailing City', contact['mailing_city'] ?? 'N/A'),
            _buildDetailRow('Mailing State', contact['mailing_state'] ?? 'N/A'),
            _buildDetailRow('Mailing Zip Code', contact['mailing_zip_code'] ?? 'N/A'),
            _buildDetailRow('Mailing Country', contact['mailing_country'] ?? 'N/A'),
            _buildDetailRow('Other Street', contact['other_street'] ?? 'N/A'),
            _buildDetailRow('Other City', contact['other_city'] ?? 'N/A'),
            _buildDetailRow('Other State', contact['other_state'] ?? 'N/A'),
            _buildDetailRow('Other Zip Code', contact['other_zip_code'] ?? 'N/A'),
            _buildDetailRow('Other Country', contact['other_country'] ?? 'N/A'),
            _buildDetailRow('Description', contact['description'] ?? 'N/A'),
            _buildDetailRow('Email Opt Out', contact['email_opt_out'] == '1' ? 'Yes' : 'No'),
            if (contact['photo'] != null && contact['photo'].isNotEmpty && File(contact['photo']!).existsSync())
              Image.file(
                File(contact['photo']!),
                height: 200,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}