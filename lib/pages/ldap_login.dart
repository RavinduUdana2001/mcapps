import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LdapLoginScreen extends StatefulWidget {
  const LdapLoginScreen({Key? key}) : super(key: key);

  @override
  _LdapLoginScreenState createState() => _LdapLoginScreenState();
}

class _LdapLoginScreenState extends State<LdapLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedCompany = 'McLarens'; // Default company selection
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("https://test.mchostlk.com/AD.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'company_name': selectedCompany!,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Log the response to console
        print('Login Response: $responseBody');

        if (responseBody.containsKey("error")) {
          setState(() {
            _errorMessage = responseBody["error"];
          });
        } else {
          // Successful login, store the user data
          await _storeUserData(responseBody);

          // Navigate to HomePage and pass user data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userData: responseBody),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = "Server error. Please try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please check your connection.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    // Get instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store the user data
    await prefs.setString('userId', userData['userId']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('mail', userData['mail']);
    await prefs.setString('department', userData['department']);
    await prefs.setString('company', userData['company']);
    await prefs.setString('title', userData['title']);
    await prefs.setString('displayname', userData['displayname']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFFB4B0FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/user.png', height: 100),
                const SizedBox(height: 30),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome back! Please login to your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),

                // Username Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Company Selection Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCompany,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCompany = newValue;
                    });
                  },
                  items: <String>['McLarens', 'GAC', 'M&D']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                ),
                const SizedBox(height: 30),

                // Display error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.blueAccent)
                      : const Text('Login', style: TextStyle(fontSize: 18.0)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
