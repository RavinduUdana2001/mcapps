import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'home_page.dart'; // Import home page
import 'ldap_login.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // For fade-in effect
  double _scale = 0.5;  // For scaling effect

  @override
  void initState() {
    super.initState();
    // Trigger the animations after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;  // Fade-in to fully visible
        _scale = 1.0;    // Scale to original size
      });
    });

    // Navigate to the main page after 3 seconds
    Timer(const Duration(seconds: 5), () {
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
                  Color(0xFF6A11CB), // Attractive purple
                  Color(0xFF2575FC), // Vibrant blue
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
                color: Colors.white.withOpacity(0.2),
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
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.yellow.shade700,
                  child: Image.asset(
                    'assets/mcapps1.png', // Your logo image
                    width: 250,  // Set the size for your logo
                    height: 250, // Set the size for your logo
                  ),
                ),
              ),
            ),
          ),

          // Optional: Add text below the logo with glow
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Welcome to McApps",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
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
