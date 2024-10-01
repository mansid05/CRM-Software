import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
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
    try {
      final response = await http.get(Uri.parse(getCallsUrl));

      if (response.statusCode == 200) {
        print('Response: ${response.body}'); // Debugging the response
        final List<dynamic> callsJson = json.decode(response.body);

        setState(() {
          _calls = callsJson.cast<Map<String, dynamic>>();
        });

        if (_calls.isEmpty) {
          print('No calls found');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching calls: $e');
    }
  }

  //Future<void> _deleteCall(int id) async {
  //     try {
  //       final response = await http.post(
  //         Uri.parse(deleteCallUrl),
  //body: json.encode({'id': id}),
  //headers: {'Content-Type': 'application/json'},
  //);

  //print('Delete response status: ${response.statusCode}');
  //print('Delete response body: ${response.body}');

  //if (response.statusCode == 200) {
  //final jsonResponse = json.decode(response.body);
  //if (jsonResponse['status'] == 'success') {
  //setState(() {
  // _calls.removeWhere((call) => call['id'] == id);
  //});
  // } else {
  // print('Failed to delete call: ${jsonResponse['message']}');
  // }
  // } else {
  // print('Failed to delete call');
  // }
  //}

  Future<void> _showCallDetails(Map<String, dynamic> call) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => CallDetailSheet(call: call),
    );
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
                    leading: CircleAvatar(
                      child: Icon(Icons.call_rounded, size: 40, color: Colors.white),
                      backgroundColor: Color(0xFF7b68ee),
                    ),
                    onTap: () {
                      _showCallDetails(call);
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
                      //_deleteCall(index);
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

class CallDetailSheet extends StatelessWidget {
  final Map<String, dynamic> call;

  CallDetailSheet({required this.call});

  @override
  Widget build(BuildContext context) {
    return Padding(
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