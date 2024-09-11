import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_call_page.dart';

class CallPage extends StatefulWidget {

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  List<Map<String, dynamic>> _calls = [];

  @override
  void initState() {
    super.initState();
    _fetchCalls();
  }

  Future<void> _fetchCalls() async {
    final prefs = await SharedPreferences.getInstance();
    final callsJson = prefs.getStringList('calls') ?? [];
    setState(() {
      _calls = callsJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteCall(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final callsJson = prefs.getStringList('calls') ?? [];
    callsJson.removeAt(index); // Remove the call from the list
    await prefs.setStringList('calls', callsJson); // Save updated list

    setState(() {
      _calls.removeAt(index); // Update UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Calls', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCallPage(),
                ),
              ).then((_) => _fetchCalls()); // Refresh calls after adding a new one
            },
          ),
        ],
      ),
      body: _calls.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Calls',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchCalls,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _calls.length,
        itemBuilder: (context, index) {
          final call = _calls[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('Outgoing call to ${call['contact']}'),
                    subtitle: Text(call['call_start_time'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallDetailPage(call: call),
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
                        title: Text('Delete Call'),
                        content: Text('Are you sure you want to delete this call?'),
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
                      _deleteCall(index);
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

class CallDetailPage extends StatelessWidget {
  final Map<String, dynamic> call;

  CallDetailPage({required this.call});

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
        title: Text('${call['contact'] ?? 'Unknown'}', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF7b68ee),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Call Type', call['call_type'] ?? 'N/A'),
            _buildDetailRow('Outgoing Call Status', call['outgoing_call_status'] ?? 'N/A'),
            _buildDetailRow('Call Start Time', call['call_start_time'] ?? 'N/A'),
            _buildDetailRow('Call Duration', call['call_duration'] ?? 'N/A'),
            _buildDetailRow('Subject', call['subject'] ?? 'N/A'),
            _buildDetailRow('Account', call['account'] ?? 'N/A'),
            _buildDetailRow('Call Purpose', call['call_purpose'] ?? 'N/A'),
            _buildDetailRow('Call Agenda', call['call_agenda'] ?? 'N/A'),
            _buildDetailRow('Call Result', call['call_result'] ?? 'N/A'),
            _buildDetailRow('Description', call['description'] ?? 'N/A'),
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