import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:flutter/services.dart';

class LdapLoginScreen extends StatefulWidget {
  const LdapLoginScreen({super.key});

  @override
  _LdapLoginScreenState createState() => _LdapLoginScreenState();
}

class _LdapLoginScreenState extends State<LdapLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedCompany = 'McLarens';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _companies = ['McLarens', 'GAC', 'M&D'];

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    int? lastLoginTime = prefs.getInt('lastLoginTime');

    if (lastLoginTime != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int oneWeekInMillis = 7 * 24 * 60 * 60 * 1000; // 7 days

      if (currentTime - lastLoginTime < oneWeekInMillis) {
        Map<String, dynamic> userData = {
          'userId': userId,
          'username': prefs.getString('username'),
          'mail': prefs.getString('mail'),
          'department': prefs.getString('department'),
          'company': prefs.getString('company'),
          'title': prefs.getString('title'),
          'displayname': prefs.getString('displayname'),
        };

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: userData)),
        );
      }
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty || selectedCompany == null) {
      setState(() {
        _errorMessage = 'Please fill all fields.';
        _isLoading = false;
      });
      return;
    }

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

        if (responseBody.containsKey("error")) {
          setState(() {
            _errorMessage = responseBody["error"];
          });
        } else {
          await _storeUserData(responseBody);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userData: responseBody),
            ),
            (route) => false,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', userData['userId']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('mail', userData['mail']);
    await prefs.setString('department', userData['department']);
    await prefs.setString('company', userData['company']);
    await prefs.setString('title', userData['title']);
    await prefs.setString('displayname', userData['displayname']);
    await prefs.setInt('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
  }

Future<bool> _onWillPop() async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Exit app immediately
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      ) ??
      false;
}


 @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: _onWillPop,
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
                             colors: [
                    Color(0xFF6378AE), // Dark Blue
                    Color(0xFF2E3A59), // Lighter Blue
                  ],
          ),
        ),
        child: Center( // Ensures everything is centered properly
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Avoids unnecessary space
              mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
              children: [
                const SizedBox(height: 50),
                Flexible( // Makes the image responsive
                  child: Image.asset('assets/mcapps.png', height: 100),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to McApps!',
                  textAlign: TextAlign.center, // Ensures text stays centered
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your enterprise solution, simplified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                _buildTextField(_usernameController, 'Username'),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', obscureText: true),
                const SizedBox(height: 20),
                // Company Dropdown with Right-aligned arrow
                _buildDropdownButton(
                  'Select Company',
                  selectedCompany,
                  (String? newValue) {
                    setState(() {
                      selectedCompany = newValue;
                    });
                  },
                  _companies,
                ),
                const SizedBox(height: 40),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 55.0),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 18.0)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  // Helper method for TextField
  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: _inputDecoration(hintText),
      style: const TextStyle(color: Colors.white),
    );
  }

  // Helper method for DropdownButton
  Widget _buildDropdownButton(
      String label, String? value, ValueChanged<String?>? onChanged, List<String> items) {
    return Container(
      width: double.infinity, // Ensures it takes the same width as other fields
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.white.withOpacity(0.15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF2E3A59),
        hint: Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        underline: Container(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
        ),
        iconSize: 30.0, // Increase icon size for better visibility
        isExpanded: true, // Ensures dropdown is as wide as the container
      ),
    );
  }

  // Input Decoration method
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
    );
  }
}
