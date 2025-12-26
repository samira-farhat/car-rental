import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // to save tokens locally
import '../../globals.dart';
import '../../main_screens/bottom_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // color to use
  final Color midnightBlue = Color(0xFF004760);

  bool _obscurePassword = true;

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter email and password"))
      );
      return;
    }

    final url = Uri.parse( 'http://localhost:8000/api/accounts/login/' );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Successful login
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login successful!"))
        );

        // Save tokens locally for authenticated requests
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);

        authToken = data['access'];

        // Navigate to main app screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BottomNavScreen(isGuest: false),
          ),
        );
      } else {
        // Error (like invalid credentials)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['detail'] ?? data['error'] ?? 'Login failed'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error connecting to server"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  'assets/images/top_login.jpeg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 10,),

                Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                  child: Semantics(
                    label: 'Email input field',
                    hint: 'Enter your email address',
                    textField: true,
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15),

                Padding(
                  padding: EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                  child: Semantics(
                    label: 'Password input field',
                    hint: 'Enter your password',
                    textField: true,
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
                      child: Semantics(
                        label: 'Forgot password button',
                        hint: 'Tap to reset your password',
                        button: true,
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

                SizedBox(height: 40),

                Semantics(
                  label: 'Login button',
                  hint: 'Tap to log into your account',
                  button: true,
                  child: ElevatedButton(
                    onPressed: loginUser, // calling the login function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: midnightBlue,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    ),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 6),

                Semantics(
                  label: 'Register button',
                  hint: 'Tap to create a new account',
                  button: true,
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

                SizedBox(height: 30),

                Image.asset(
                  'assets/images/bottom_login.jpeg',
                  fit: BoxFit.fitWidth,
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
