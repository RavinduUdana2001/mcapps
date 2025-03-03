import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class McAlertsPage extends StatefulWidget {
  final String? alertMessage;
  const McAlertsPage({super.key, this.alertMessage});

  @override
  _McAlertsPageState createState() => _McAlertsPageState();
}

class _McAlertsPageState extends State<McAlertsPage> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  late WebSocketChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeWebSocket();
    _fetchMessages();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _navigateToMessage(response.payload!);
        }
      },
    );
  }

  void _initializeWebSocket() {
    channel = IOWebSocketChannel.connect('ws://test.mchostlk.com:8443');

    channel.stream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket Closed');
      },
    );
  }

  void _handleWebSocketMessage(String message) {
    try {
      final decodedMessage = json.decode(message);
      if (decodedMessage.containsKey('title') && decodedMessage.containsKey('message')) {
        _showNotification(decodedMessage['title'], decodedMessage['message']);
        _fetchMessages();
      }
    } catch (error) {
      print('Error decoding WebSocket message: $error');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alert_channel',
      'McAlerts',
      channelDescription: 'Alerts for important messages',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: json.encode({'title': title, 'message': body}),
    );
  }

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
    }
  }

  Future<void> _onRefresh() async {
    await _fetchMessages();
  }

  void _navigateToMessage(String payload) {
    final decodedPayload = json.decode(payload);
    if (decodedPayload != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageDetailPage(message: decodedPayload),
        ),
      );
    }
  }

  // Helper function to truncate text to 20 words
  String _truncateTo20Words(String text) {
    final words = text.split(' ');
    if (words.length > 20) {
      return '${words.take(20).join(' ')}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'McAlerts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6378AE),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _messages.isEmpty
                  ? const Center(child: Text("No messages available", style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        var message = _messages[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageDetailPage(message: message),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['title'],
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _truncateTo20Words(message['message']), // Truncate to 20 words
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Published on: ${message['created_at']}',
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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

class MessageDetailPage extends StatelessWidget {
  final dynamic message;
  const MessageDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        backgroundColor: const Color(0xFF6378AE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),
            Text(message['message'], style: const TextStyle(fontSize: 18, color: Colors.black87)), // Full message
            const SizedBox(height: 20),
            Text('Published on: ${message['created_at']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}