import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_deals_page.dart';

class DealPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  DealPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _DealPageState createState() => _DealPageState();
}

class _DealPageState extends State<DealPage> {
  List<Map<String, dynamic>> _deals = [];

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    final prefs = await SharedPreferences.getInstance();
    final dealsJson = prefs.getStringList('deals') ?? [];
    setState(() {
      _deals = dealsJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteDeal(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final dealsJson = prefs.getStringList('deals') ?? [];
    dealsJson.removeAt(index); // Remove the deal from the list
    await prefs.setStringList('deals', dealsJson); // Save updated list

    setState(() {
      _deals.removeAt(index); // Update UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Deals', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDealPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                  ),
                ),
              ).then((_) => _fetchDeals()); // Refresh deals after adding a new one
            },
          ),
        ],
      ),
      body: _deals.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Deals',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchDeals,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _deals.length,
        itemBuilder: (context, index) {
          final deal = _deals[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${deal['first_name']} ${deal['last_name']}'),
                    subtitle: Text(deal['deal_name'] ?? 'deal Name'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DealDetailPage(deal: deal),
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
                        title: Text('Delete Deal'),
                        content: Text('Are you sure you want to delete this deal?'),
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
                      _deleteDeal(index);
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

class DealDetailPage extends StatelessWidget {
  final Map<String, dynamic> deal;

  DealDetailPage({required this.deal});

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
        title: Text('${deal['first_name'] ?? 'Unknown'} ${deal['last_name'] ??
            'Unknown'}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Deal Information Section
            _buildDetailRow('Deal Name', deal['deal_name'] ?? 'N/A'),
            _buildDetailRow('Account Name', deal['account_name'] ?? 'N/A'),
            _buildDetailRow('Amount', deal['amount'] ?? 'N/A'),
            _buildDetailRow('Closing Date', deal['closing_date'] ?? 'N/A'),
            _buildDetailRow('Stage', deal['stage'] ?? 'N/A'),
            _buildDetailRow('Type', deal['type'] ?? 'N/A'),
            _buildDetailRow('Next Step', deal['next_step'] ?? 'N/A'),
            _buildDetailRow('Probability', deal['probability'] ?? 'N/A'),
            _buildDetailRow('Lead Source', deal['lead_source'] ?? 'N/A'),
            _buildDetailRow('Expected Revenue',
                deal['expected_revenue'].toString() ?? 'N/A'),
            _buildDetailRow('Contact Name', deal['contact_name'] ?? 'N/A'),
            _buildDetailRow(
                'Campaign Source', deal['campaignSource']?.toString() ?? 'N/A'),

            // Additional Information
            _buildDetailRow('Description', deal['description'] ?? 'N/A'),
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