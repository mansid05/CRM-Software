import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
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
    try {
      final response = await http.get(Uri.parse(getDealsUrl));

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final List<dynamic> dealsJson = json.decode(response.body);

        setState(() {
          _deals = dealsJson.cast<Map<String, dynamic>>();
        });

        if (_deals.isEmpty) {
          print('No deals found');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching deals: $e'); // Will display any connection or parsing errors
    }
  }

  Future<void> _deleteDeal(int id) async {
    try {
      final response = await http.post(
        Uri.parse(deleteDealUrl),
        body: json.encode({'id': id}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _deals.removeWhere((deal) => deal['id'] == id);
        });
      } else {
        print('Failed to delete deal');
      }
    } catch (e) {
      print('Error deleting deal: $e');
    }
  }

  Future<void> _showDealDetails(Map<String, dynamic> deal) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => DealDetailSheet(deal: deal),
    );
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
                    title: Text('${deal['first_name'] ?? ''} ${deal['last_name'] ?? ''}'),
                    subtitle: Text(deal['deal_name'] ?? 'Deal Name'),
                    onTap: () {
                      _showDealDetails(deal);
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
                      _deleteDeal(deal['id']); // Pass the deal ID instead of index
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

class DealDetailSheet extends StatelessWidget {
  final Map<String, dynamic> deal;

  DealDetailSheet({required this.deal});

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
        title: Text('${deal['first_name'] ?? 'Unknown'} ${deal['last_name'] ?? 'Unknown'}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Deal Name', deal['deal_name'] ?? 'N/A'),
            _buildDetailRow('Account Name', deal['account_name'] ?? 'N/A'),
            _buildDetailRow('Amount', deal['amount']?.toString() ?? 'N/A'),
            _buildDetailRow('Closing Date', deal['closing_date'] ?? 'N/A'),
            _buildDetailRow('Stage', deal['stage'] ?? 'N/A'),
            _buildDetailRow('Type', deal['type'] ?? 'N/A'),
            _buildDetailRow('Next Step', deal['next_step'] ?? 'N/A'),
            _buildDetailRow('Probability', deal['probability']?.toString() ?? 'N/A'),
            _buildDetailRow('Lead Source', deal['lead_source'] ?? 'N/A'),
            _buildDetailRow('Expected Revenue', deal['expected_revenue']?.toString() ?? 'N/A'),
            _buildDetailRow('Contact Name', deal['contact_name'] ?? 'N/A'),
            _buildDetailRow('Campaign Source', deal['campaign_source'] ?? 'N/A'),
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