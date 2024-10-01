import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'add_meeting_page.dart';

class MeetingPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  MeetingPage({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  List<Map<String, dynamic>> _meetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    try {
      final response = await http.get(Uri.parse(getMeetingsUrl));

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final List<dynamic> meetingsJson = json.decode(response.body);

        setState(() {
          _meetings = meetingsJson.cast<Map<String, dynamic>>();
        });

        if (_meetings.isEmpty) {
          print('No meetings found');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching meetings: $e'); // Will display any connection or parsing errors
    }
  }

  //Future<void> _deleteMeeting(int id) async {
  //     try {
  //       final response = await http.post(
  //         Uri.parse(deleteMeetingUrl),
  //       body: json.encode({'id': id}),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _meetings.removeWhere((meeting) => meeting['id'] == id);
  //       });
  //     } else {
  //       print('Failed to delete meeting');
  //     }
  //   } catch (e) {
  //     print('Error deleting meeting: $e');
  //   }
  // }

  Future<void> _showMeetingDetails(Map<String, dynamic> meeting) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => MeetingDetailSheet(meeting: meeting),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Meetings', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7b68ee),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMeetingPage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                  ),
                ),
              ).then((_) => _fetchMeetings()); // Refresh meetings after adding a new one
            },
          ),
        ],
      ),
      body: _meetings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No Meetings',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            TextButton(
              onPressed: _fetchMeetings,
              child: Text('Refresh'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(meeting['host'] ?? ''),
                    subtitle: Text(meeting['title'] ?? ''),
            leading: CircleAvatar(
              child: Icon(Icons.meeting_room, size: 40, color: Colors.white),
              backgroundColor: Color(0xFF7b68ee),
            ),
            onTap: () {
              _showMeetingDetails(meeting);
              },
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFF7b68ee)),
                  onPressed: () async {
                    final shouldDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Meeting'),
                        content: Text('Are you sure you want to delete this meeting?'),
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
                      //_deleteMeeting(index);
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

class MeetingDetailSheet extends StatelessWidget {
  final Map<String, dynamic> meeting;

  MeetingDetailSheet({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
            _buildDetailRow('Title', meeting['title'] ?? 'N/A'),
            _buildDetailRow('From', meeting['from'] ?? 'N/A'),
            _buildDetailRow('To', meeting['to'] ?? 'N/A'),
            _buildDetailRow('All Day', meeting['all_day'] == '1' ? 'Yes' : 'No'),
            _buildDetailRow('Contact', meeting['contact'] ?? 'N/A'),
            _buildDetailRow('Account', meeting['account'] ?? 'N/A'),
            _buildDetailRow('Location', meeting['location'] ?? 'N/A'),
            _buildDetailRow('Participants', meeting['participants'] ?? 'N/A'),
            _buildDetailRow('Repeat', meeting['repeat'] ?? 'N/A'),
            _buildDetailRow('Description', meeting['description'] ?? 'N/A'),
            _buildDetailRow('Remainder', meeting['remainder'] ?? 'N/A'),
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