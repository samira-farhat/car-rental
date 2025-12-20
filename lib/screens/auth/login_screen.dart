import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // color to use
  final Color midnightBlue = Color(0xFF004760);

  bool _obscurePassword= true;

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter email and password"))
      );
      return;
    }

    final url = Uri.parse('http://192.168.0.110:8000/api/accounts/login/');


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

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }else {
        // Error (like invalid credentials)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Login failed'))
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
      body: Stack(
        children: [
          // for the background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // overlaying the login form
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(40.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Semantics(
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

                    SizedBox(height: 15),

                    Semantics(
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

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Semantics(
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
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
