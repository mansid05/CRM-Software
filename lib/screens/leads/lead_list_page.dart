import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_lead_page.dart';

class LeadListPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  LeadListPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _LeadListPageState createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  List<Map<String, dynamic>> _leads = [];

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    final prefs = await SharedPreferences.getInstance();
    final leadsJson = prefs.getStringList('leads') ?? [];
    setState(() {
      _leads = leadsJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteLead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final leadsJson = prefs.getStringList('leads') ?? [];
    leadsJson.removeAt(index); // Remove the lead from the list
    await prefs.setStringList('leads', leadsJson); // Save updated list

    setState(() {
      _leads.removeAt(index); // Update UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Leads', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLeadPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                  ),
                ),
              ).then((_) => _fetchLeads()); // Refresh leads after adding a new one
            },
          ),
        ],
      ),
      body: _leads.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Leads',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchLeads,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _leads.length,
        itemBuilder: (context, index) {
          final lead = _leads[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${lead['first_name']} ${lead['last_name']}'),
                    subtitle: Text(lead['company'] ?? 'No Company'),
                    leading: lead['photo'] != null && lead['photo'].isNotEmpty
                        ? CircleAvatar(
                      backgroundImage: FileImage(File(lead['photo']!)),
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
                          builder: (context) => LeadDetailPage(lead: lead),
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
                        title: Text('Delete Lead'),
                        content: Text('Are you sure you want to delete this lead?'),
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
                      _deleteLead(index);
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

class LeadDetailPage extends StatelessWidget {
  final Map<String, dynamic> lead;

  LeadDetailPage({required this.lead});

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
        title: Text('${lead['first_name'] ?? 'Unknown'} ${lead['last_name'] ?? 'Unknown'}', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Company', lead['company'] ?? 'N/A'),
            _buildDetailRow('Title', lead['title'] ?? 'N/A'),
            _buildDetailRow('Email', lead['email'] ?? 'N/A'),
            _buildDetailRow('Phone', lead['phone'] ?? 'N/A'),
            _buildDetailRow('Mobile', lead['mobile'] ?? 'N/A'),
            _buildDetailRow('Website', lead['website'] ?? 'N/A'),
            _buildDetailRow('Lead Source', lead['lead_source'] ?? 'N/A'),
            _buildDetailRow('Lead Status', lead['lead_status'] ?? 'N/A'),
            _buildDetailRow('Industry', lead['industry'] ?? 'N/A'),
            _buildDetailRow('No. of Employees', lead['no_of_employees']?.toString() ?? 'N/A'),
            _buildDetailRow('Annual Revenue', lead['annual_revenue']?.toString() ?? 'N/A'),
            _buildDetailRow('Rating', lead['rating'] ?? 'N/A'),
            _buildDetailRow('Skype ID', lead['skype_id'] ?? 'N/A'),
            _buildDetailRow('Secondary Email', lead['secondary_email'] ?? 'N/A'),
            _buildDetailRow('Twitter', lead['twitter'] ?? 'N/A'),
            _buildDetailRow('Street', lead['street'] ?? 'N/A'),
            _buildDetailRow('City', lead['city'] ?? 'N/A'),
            _buildDetailRow('State', lead['state'] ?? 'N/A'),
            _buildDetailRow('Zip Code', lead['zip_code'] ?? 'N/A'),
            _buildDetailRow('Country', lead['country'] ?? 'N/A'),
            _buildDetailRow('Description', lead['description'] ?? 'N/A'),
            _buildDetailRow('Email Opt Out', lead['email_opt_out'] == '1' ? 'Yes' : 'No'),
            if (lead['photo'] != null && lead['photo'].isNotEmpty && File(lead['photo']!).existsSync())
              Image.file(
                File(lead['photo']!),
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