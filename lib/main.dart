import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';
import 'pages/mcalets.dart';

class MessageDetailPage extends StatelessWidget {
  final dynamic message;
  const MessageDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          message['title'],
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['title'],
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              message['message'],
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Text(
              'Published on: ${message['created_at']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("b8137ddd-bcc9-4647-91e9-4e8ca1416b4a"); // Replace with your OneSignal App ID

  // Request notification permission
  OneSignal.Notifications.requestPermission(true);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? userData;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? notificationPayload;
  bool isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _initializeNotifications();
    _initializeOneSignal();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          notificationPayload = response.payload;
          _navigateToMessageDetailPage();
        }
      },
    );
  }

  Future<void> fetchUserData() async {
    final response =
        await http.get(Uri.parse('https://test.mchostlk.com/AD.php'));

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          userData = json.decode(response.body);
        });
        if (userData != null) {
          _checkNotificationPermission();
        }
      }
    } else {
      print('Failed to load user data');
    }
  }

  void _initializeOneSignal() {
    // Handle notifications when the app is in the foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      _showNotification(event.notification.title ?? "New Message", event.notification.body ?? "You have a new message");
    });

    // Handle notifications when the app is in the background or terminated
    OneSignal.Notifications.addClickListener((event) {
      final notification = event.notification;
      _navigateToMcAlertsPage(
        title: notification.title ?? "New Message",
        message: notification.body ?? "You have a new message",
      );
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'This is your notification channel',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: json.encode({'title': title, 'message': body}),
    );
  }

  void _navigateToMcAlertsPage({String? title, String? message}) {
    if (title != null && message != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => McAlertsPage(
            alertMessage: json.encode({'title': title, 'message': message}),
          ),
        ),
      );
    }
  }

  void _navigateToMessageDetailPage() {
    if (notificationPayload != null) {
      final decodedPayload = json.decode(notificationPayload!);
      if (decodedPayload != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MessageDetailPage(
              message: decodedPayload,
            ),
          ),
        );
      }
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> _checkNotificationPermission() async {
    if (isFirstLaunch) {
      final status = await Permission.notification.request();

      if (status.isGranted) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }

      setState(() {
        isFirstLaunch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'McApps',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: userData == null ? '/splash' : '/',
      routes: {
        '/': (context) => userData != null
            ? HomePage(userData: userData!)
            : const SplashScreen(),
        '/splash': (context) => const SplashScreen(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          return userData != null
              ? HomePage(userData: userData!)
              : const SplashScreen();
        });
      },
    );
  }
}