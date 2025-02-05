import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? userData; // Store user data

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response = await http.get(Uri.parse('https://test.mchostlk.com/AD.php'));

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
      });
    } else {
      print('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Access App',
      debugShowCheckedModeBanner: false,
      initialRoute: userData == null ? '/splash' : '/', // Ensure proper routing
      routes: {
        '/': (context) => userData != null
            ? HomePage(userData: userData!) // Pass user data
            : const SplashScreen(),
        '/splash': (context) => const SplashScreen(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          return userData != null ? HomePage(userData: userData!) : const SplashScreen();
        });
      },
    );
  }
}
