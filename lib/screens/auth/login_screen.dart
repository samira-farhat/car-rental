import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {

  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
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
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Semantics(
                label: 'Password input field',
                hint: 'Enter your password',
                textField: true,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 6),

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
                            color: Colors.cyan,
                          ),
                        ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              Semantics(
                label: 'Login button',
                hint: 'Tap to log into your account',
                button: true,
                child: ElevatedButton(
                  onPressed: () {
                    //Navigator.pushNamed(context, '/browse'); takes u to appropriate dashboard/ screen after checking role
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
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
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
