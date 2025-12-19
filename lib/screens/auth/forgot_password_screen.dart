import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {

  final TextEditingController emailController= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'Enter your email to reset your password',
                  style: TextStyle(
                      fontSize: 16
                  ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if(emailController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter your email')),
                    );
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password reset link sent to ${emailController.text}')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),

                ),
                child: Text(
                  'RESET PASSWORD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
