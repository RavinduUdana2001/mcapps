import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mcalets.dart';
import 'moreapps.dart';
import 'ldap_login.dart';
import 'news.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    const String headerImage = 'assets/678.jpg';
    const String logoImage = 'assets/mcapps.png';

    final List<Map<String, String>> firstRowItems = [
      {
        'name': 'Group Intranet',
        'icon': 'fa-solid fa-users',
        'url': 'https://intranet.mclarens.lk',
      },
      {
        'name': 'Web Mail Login',
        'icon': 'fa-solid fa-envelope',
        'url': 'https://outlook.cloud.microsoft/mail/',
      },
      {
        'name': 'HRIS Portal',
        'icon': 'fa-solid fa-chalkboard-user',
        'url': 'https://mhl.peopleshr.com/hr/',
      },
    ];

    final List<Map<String, dynamic>> secondRowItems = [
      {
        'name': 'Mc Alerts',
        'icon': 'fa-solid fa-bell',
        'page': const McAlertsPage(),
      },
      {
        'name': 'News and Events',
        'icon': 'fa-solid fa-newspaper',
        'page': const News(),
      },
      {
        'name': 'More Apps',
        'icon': 'fa-solid fa-ellipsis-h',
        'page': const MoreApps(),
      },
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      final IOSFlutterLocalNotificationsPlugin? iosNotifications =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      // Check if it's not null and then request permission
      if (iosNotifications != null) {
        final bool? granted = await iosNotifications.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        if (granted ?? false) {
          print('Notification permission granted');
        } else {
          print('Notification permission denied');
        }
      } else {
        print('iOS notification plugin not available.');
      }
    });

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // This exits the app
        return false; // Prevents navigating back
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 5,
          title: Row(
            children: [
              Image.asset(
                logoImage,
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 10),
              const Text(
                'McLarens Group',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6378AE), // Solid Dark Blue Color
            ),
          ),
        ),
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6378AE), // Dark Blue
                    Color(0xFFD2D8E8), // Lighter Blue
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Text at the Top
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userData['displayname']!,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header Image with Climate Widget
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 210,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            headerImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Climate Widget Positioned Top-Left
                      const Positioned(
                        top: 20,
                        left: 30,
                        child: ClimateWidget(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // First Row of Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(firstRowItems.length, (index) {
                      final item = firstRowItems[index];
                      return _buildCard(context, item);
                    }),
                  ),
                  const SizedBox(height: 40),
                  // Second Row of Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(secondRowItems.length, (index) {
                      final item = secondRowItems[index];
                      return _buildCard(context, item);
                    }),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get greeting based on time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        if (item['url'] != null) {
          _launchURL(item['url']!);
        } else if (item['page'] is Widget) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['page'] as Widget),
          );
        }
      },
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 110,
          width: 100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  _getIcon(item['icon']!),
                  size: 35,
                  color: const Color(0xFF003764),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    item['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fa-solid fa-users':
        return FontAwesomeIcons.users;
      case 'fa-solid fa-envelope':
        return FontAwesomeIcons.envelope;
      case 'fa-solid fa-chalkboard-user':
        return FontAwesomeIcons.chalkboardUser;
      case 'fa-solid fa-ellipsis-h':
        return FontAwesomeIcons.ellipsisH;
      case 'fa-solid fa-bell':
        return FontAwesomeIcons.bell;
      case 'fa-solid fa-newspaper':
        return FontAwesomeIcons.newspaper;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear user session data
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const LdapLoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Climate Widget
class ClimateWidget extends StatefulWidget {
  const ClimateWidget({super.key});

  @override
  _ClimateWidgetState createState() => _ClimateWidgetState();
}

class _ClimateWidgetState extends State<ClimateWidget> {
  String temperature = '--°C';
  String weatherIcon = 'assets/sunny.png'; // Default icon

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    const String apiKey = '3222bbdb39f967da86d6873a58b25b9d';
    const String city = 'Colombo'; // Replace with your city
    const String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = '${data['main']['temp'].round()}°C';
          final weatherCondition = data['weather'][0]['main'];
          weatherIcon = _getWeatherIcon(weatherCondition);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/sunny.png';
      case 'clouds':
        return 'assets/cloudy.png';
      case 'rain':
        return 'assets/rainy.png';
      case 'snow':
        return 'assets/snowy.png';
      default:
        return 'assets/sunny.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            weatherIcon,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 5),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}