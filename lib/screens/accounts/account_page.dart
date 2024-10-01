import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'add_account_page.dart';

class AccountPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  AccountPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Map<String, dynamic>> _accounts = [];

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    try {
      final response = await http.get(Uri.parse(getAccountsUrl));

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final List<dynamic> accountsJson = json.decode(response.body);

        setState(() {
          _accounts = accountsJson.cast<Map<String, dynamic>>();
        });

        if (_accounts.isEmpty) {
          print('No accounts found');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching accounts: $e');  // Will display any connection or parsing errors
    }
  }


  //Future<void> _deleteAccount(int id) async {
  //     try {
  //       final response = await http.post(
  //         Uri.parse(deleteAccountUrl),
  //body: json.encode({'id': id}),
  //headers: {'Content-Type': 'application/json'},
  //);

  //print('Delete response status: ${response.statusCode}');
  //print('Delete response body: ${response.body}');

  //if (response.statusCode == 200) {
  //final jsonResponse = json.decode(response.body);
  //if (jsonResponse['status'] == 'success') {
  //setState(() {
  // _accounts.removeWhere((account) => account['id'] == id);
  //});
  // } else {
  // print('Failed to delete account: ${jsonResponse['message']}');
  // }
  // } else {
  // print('Failed to delete account');
  // }
  //}

  Future<void> _showAccountDetails(Map<String, dynamic> account) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccountDetailSheet(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Accounts', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAccountPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                  ),
                ),
              ).then((_) => _fetchAccounts());
            },
          ),
        ],
      ),
      body: _accounts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Accounts',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchAccounts,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('${account['first_name']} ${account['last_name']}'),
                    subtitle: Text(account['account_number'] ?? 'Account Number'),
                    leading: CircleAvatar(
                      child: Icon(Icons.account_circle, size: 40, color: Colors.white),
                      backgroundColor: Color(0xFF7b68ee),
                    ),
                    onTap: () {
                      _showAccountDetails(account);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFF7b68ee)),
                  onPressed: () async {
                    final shouldDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Account'),
                        content: Text('Are you sure you want to delete this account?'),
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
                      //_deleteAccount(index);
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

class AccountDetailSheet extends StatelessWidget {
  final Map<String, dynamic> account;

  AccountDetailSheet({required this.account});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDetailRow('Account Name', account['account_name'] ?? 'N/A'),
          _buildDetailRow('Account Number', account['account_number'] ?? 'N/A'),
          _buildDetailRow('Phone', account['phone'] ?? 'N/A'),
          _buildDetailRow('Account Type', account['account_type'] ?? 'N/A'),
          _buildDetailRow('Employees', account['employees']?.toString() ?? 'N/A'),
          _buildDetailRow('Annual Revenue', account['annual_revenue']?.toString() ?? 'N/A'),
          // Billing Address Heading
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Billing Address',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _buildDetailRow('Billing Street', account['billing_street'] ?? 'N/A'),
          _buildDetailRow('Billing City', account['billing_city'] ?? 'N/A'),
          _buildDetailRow('Billing State', account['billing_state'] ?? 'N/A'),
          _buildDetailRow('Billing Zip Code', account['billing_zip_code'] ?? 'N/A'),
          _buildDetailRow('Billing Country', account['billing_country'] ?? 'N/A'),
          // Shipping Address Heading
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Shipping Address',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _buildDetailRow('Shipping Street', account['shipping_street'] ?? 'N/A'),
          _buildDetailRow('Shipping City', account['shipping_city'] ?? 'N/A'),
          _buildDetailRow('Shipping State', account['shipping_state'] ?? 'N/A'),
          _buildDetailRow('Shipping Zip Code', account['shipping_zip_code'] ?? 'N/A'),
          _buildDetailRow('Shipping Country', account['shipping_country'] ?? 'N/A'),

          _buildDetailRow('Rating', account['rating'] ?? 'N/A'),
          _buildDetailRow('Fax', account['fax'] ?? 'N/A'),
          _buildDetailRow('Account Site', account['account_site'] ?? 'N/A'),
          _buildDetailRow('Parent Account', account['parent_account'] ?? 'N/A'),
          _buildDetailRow('Website', account['website'] ?? 'N/A'),
          _buildDetailRow('Ticker Symbol', account['ticker_symbol'] ?? 'N/A'),
          _buildDetailRow('Ownership', account['ownership'] ?? 'N/A'),
          _buildDetailRow('Industry', account['industry'] ?? 'N/A'),
          _buildDetailRow('SIC Code', account['sic_code'] ?? 'N/A'),
          _buildDetailRow('Description', account['description'] ?? 'N/A'),
        ],
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
