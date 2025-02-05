import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class McAlertsPage extends StatefulWidget {
  @override
  _McAlertsPageState createState() => _McAlertsPageState();
}

class _McAlertsPageState extends State<McAlertsPage> {
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // Fetch data from backend
  Future<void> _fetchMessages() async {
    final response =
        await http.get(Uri.parse('https://test.mchostlk.com/get_messages.php'));

    if (response.statusCode == 200) {
      setState(() {
        _messages = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load messages');
    }
  }

  // Refresh function
  Future<void> _onRefresh() async {
    await _fetchMessages();
  }

  // Function to get the first 20 words of the message
  String _getMessageSnippet(String message) {
    List<String> words = message.split(' ');
    if (words.length > 10) {
      words = words.sublist(0, 10);
      return words.join(' ') + '...';
    } else {
      return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: Text(
    'McAlerts',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: Colors.white, // Set text color to white
    ),
  ),
  backgroundColor: Colors.blueAccent, // Vibrant blue color
  elevation: 4,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [const Color.fromRGBO(68, 138, 255, 1), Colors.blue], // Softer blue gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _messages.isEmpty
                  ? Center(
                      child: Text("No messages available",
                          style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        var message = _messages[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageDetailPage(
                                  message: message,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(16),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // Rounded corners
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['title'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromRGBO(0, 55, 100, 1), // Blue for title
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _getMessageSnippet(message['message']), // Displaying the snippet
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Published on: ${message['created_at']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// Detailed message page
// Detailed message page
class MessageDetailPage extends StatelessWidget {
  final dynamic message;

  MessageDetailPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          message['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white, // Title color set to white
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              message['title'],
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 11, 23), // Consistent blue color
              ),
            ),
            SizedBox(height: 20),
            // Message Section
            Text(
              message['message'],
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            // Created At Section
            Text(
              'Published on: ${message['created_at']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

