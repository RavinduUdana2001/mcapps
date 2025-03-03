import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'home_page.dart';
import 'ldap_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // Fade-in effect
  double _scale = 0.5;  // Scale-up effect

  @override
  void initState() {
    super.initState();
    // Trigger animations
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Check if user is already logged in before navigating
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    int? lastLoginTime = prefs.getInt('lastLoginTime');

    if (lastLoginTime != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int oneWeekInMillis = 7 * 24 * 60 * 60 * 1000; // 7 days

      if (currentTime - lastLoginTime < oneWeekInMillis) {
        // User is logged in, navigate to HomePage
        Map<String, dynamic> userData = {
          'userId': userId,
          'username': prefs.getString('username'),
          'mail': prefs.getString('mail'),
          'department': prefs.getString('department'),
          'company': prefs.getString('company'),
          'title': prefs.getString('title'),
          'displayname': prefs.getString('displayname'),
        };

        Future.delayed(const Duration(seconds: 5), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userData: userData)),
          );
        });
        return;
      }
    }

    // No session found, navigate to Login Page after splash
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LdapLoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                    Color(0xFF6378AE), // Dark Blue
                    Color(0xFF2E3A59), // Lighter Blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative top wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: 180,
               
              ),
            ),
          ),

          // Shimmering logo animation
          Center(
  child: AnimatedOpacity(
    opacity: _opacity, // Fade-in effect
    duration: const Duration(seconds: 1),
    child: AnimatedScale(
      scale: _scale, // Scale-up effect
      duration: const Duration(seconds: 1),
      child: Image.asset(
        'assets/loading-logo.png', // Logo image
        width: 300,
        height: 300,
      ),
    ),
  ),
),


          // Glowing welcome text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Welcome to McApps Testing version",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.yellow.shade700,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for the wave-like design
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
