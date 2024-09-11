import 'dart:convert';
import 'package:crm_primine/screens/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Check for admin credentials
    if (email == 'admin@gmail.com' && password == 'admin@123') {
      // Pass to admin navigation (you need to define AdminDashboardPage or similar)
      return;
    }

    var url = Uri.parse('http://192.168.31.241/login.php'); // Replace with your server URL
    var response = await http.post(url, body: {
      'email': email,
      'password': password,
    });

    print('Response: ${response.body}'); // Debugging statement

    var jsonResponse = json.decode(response.body);

    if (jsonResponse['success']) {
      String firstName = jsonResponse['firstName'];
      String lastName = jsonResponse['lastName'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Primine CRM',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF7b68ee),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7b68ee),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Color(0xFF7b68ee)),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: Color(0xFF7b68ee)),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF7b68ee),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7b68ee),
              ),
              child: Text('Log In', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7b68ee),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
