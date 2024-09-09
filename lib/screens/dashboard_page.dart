import 'package:crm_primine/screens/accounts/account_page.dart';
import 'package:flutter/material.dart';
import 'contacts/contact_page.dart';
import 'leads/lead_list_page.dart'; // Ensure this import is correct

class DashboardPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;

  DashboardPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primine CRM'),
        backgroundColor: Color(0xFF7b68ee),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('$firstName $lastName'),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${firstName[0]}',
                  style: TextStyle(fontSize: 40.0, color: Colors.black),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF7b68ee),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardPage(firstName: firstName, lastName: lastName, email: email),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Leads'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadListPage(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text('Contacts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPage(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Accounts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountPage(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Deals'),
              onTap: () {
                // Handle deals navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Tasks'),
              onTap: () {
                // Handle tasks navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.meeting_room),
              title: Text('Meetings'),
              onTap: () {
                // Handle meetings navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.call),
              title: Text('Calls'),
              onTap: () {
                // Handle calls navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.sync_disabled),
              title: Text('Unsynced Record'),
              onTap: () {
                // Handle unsynced record navigation
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () {
                // Handle settings navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                // Handle feedback navigation
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'DASHBOARD',
              style: TextStyle(fontSize: 30, color: Color(0xFF7b68ee)),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(10),
                children: <Widget>[
                  _buildCard(context, 'Confirmed Lead', Icons.add_circle),
                  _buildCard(context, 'Lead Listing', Icons.person),
                  _buildCard(context, 'Create Task', Icons.add_task),
                  _buildCard(context, 'Task Status', Icons.toggle_on),
                  _buildCard(context, 'Analyze', Icons.analytics),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
    return Card(
      color: Color(0xFF7b68ee),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (title == 'Lead Listing') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeadListPage(
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No action defined for $title')),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
