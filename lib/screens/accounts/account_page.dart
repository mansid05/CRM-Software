import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList('accounts') ?? [];
    setState(() {
      _accounts = accountsJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteAccount(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList('accounts') ?? [];
    accountsJson.removeAt(index); // Remove the account from the list
    await prefs.setStringList('accounts', accountsJson); // Save updated list

    setState(() {
      _accounts.removeAt(index); // Update UI
    });
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
              ).then((_) => _fetchAccounts()); // Refresh accounts after adding a new one
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
                    subtitle: Text(account['account_name'] ?? 'Account Name'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountDetailPage(account: account),
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
                      _deleteAccount(index);
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

class AccountDetailPage extends StatelessWidget {
  final Map<String, dynamic> account;

  AccountDetailPage({required this.account});

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
        title: Text('${account['first_name'] ?? 'Unknown'} ${account['last_name'] ?? 'Unknown'}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Account Information Section
            _buildDetailRow('Account Name', account['account_name'] ?? 'N/A'),
            _buildDetailRow('Phone', account['phone'] ?? 'N/A'),
            _buildDetailRow('Account Site', account['account_site'] ?? 'N/A'),
            _buildDetailRow('Parent Account', account['parent_account'] ?? 'N/A'),
            _buildDetailRow('Website', account['website'] ?? 'N/A'),
            _buildDetailRow('Account Number', account['account_number'] ?? 'N/A'),
            _buildDetailRow('Ticker Symbol', account['ticker_symbol'] ?? 'N/A'),
            _buildDetailRow('Account Type', account['account_type'] ?? 'N/A'),
            _buildDetailRow('Ownership', account['ownership'] ?? 'N/A'),
            _buildDetailRow('Industry', account['industry'] ?? 'N/A'),
            _buildDetailRow('Employees', account['employees']?.toString() ?? 'N/A'),
            _buildDetailRow('Annual Revenue', account['annual_revenue']?.toString() ?? 'N/A'),
            _buildDetailRow('Rating', account['rating'] ?? 'N/A'),

            // Billing and Shipping Addresses
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Billing Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildAddressSection('Billing', account),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Shipping Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildAddressSection('Shipping', account),

            // Additional Information
            _buildDetailRow('Description', account['description'] ?? 'N/A'),
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

  Widget _buildAddressSection(String addressType, Map<String, dynamic> account) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailRow('$addressType Street', account['${addressType.toLowerCase()}_street'] ?? 'N/A')),
            SizedBox(width: 10),
            Expanded(child: _buildDetailRow('$addressType City', account['${addressType.toLowerCase()}_city'] ?? 'N/A')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildDetailRow('$addressType State', account['${addressType.toLowerCase()}_state'] ?? 'N/A')),
            SizedBox(width: 10),
            Expanded(child: _buildDetailRow('$addressType Zip Code', account['${addressType.toLowerCase()}_zip_code'] ?? 'N/A')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildDetailRow('$addressType Country', account['${addressType.toLowerCase()}_country'] ?? 'N/A')),
          ],
        ),
      ],
    );
  }
}