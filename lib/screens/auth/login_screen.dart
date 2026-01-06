import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main_screens/bottom_nav_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../manager_screens/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final Color midnightBlue = Color(0xFF004760);

  bool _obscurePassword = true;

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    final url = Uri.parse('http://localhost:8000/api/accounts/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access'];
        final role = data['role'];

        await storage.write(key: 'access', value: token);
        await storage.write(key: 'role', value: role);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminGridDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BottomNavScreen(isGuest: false),
            ),
          );
        }
      } else {
        if (data['error'] == 'Please verify your account first') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please verify your email first')),
          );

          Navigator.pushReplacementNamed(
            context,
            '/verify',
            arguments: {'email': email, 'password': password},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error connecting to server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Image
              Semantics(
                label: 'Top login image',
                image: true,
                child: Image.asset(
                  'assets/images/top_login.jpeg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 10),

              // Email Input
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: "Enter your email address",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Password Input
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                child: TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: "Enter your password",
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility
                      ),
                      tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                    child: Semantics(
                      label: 'Forgot password button',
                      hint: 'Tap to reset your password',
                      button: true,
                      focusable: true,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot_password');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: midnightBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Login Button
              Semantics(
                label: 'Login button',
                hint: 'Tap to log into your account',
                button: true,
                focusable: true,
                child: ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: midnightBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Register Button
              Semantics(
                label: 'Register button',
                hint: 'Tap to create a new account',
                button: true,
                focusable: true,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(
                      color: midnightBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Bottom Image
              Semantics(
                label: 'Bottom login image',
                image: true,
                child: Image.asset(
                  'assets/images/bottom_login.jpeg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
