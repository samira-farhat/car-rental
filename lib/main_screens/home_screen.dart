import 'package:flutter/material.dart';

import 'bottom_nav_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Home Screen!',
              style: TextStyle(fontSize: 20),
            ),

            SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BottomNavScreen(isGuest: true),
                  ),
                );
              },
              child: Text('Browse as Guest'),
            ),

            SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('login'),
            ),
          ],
        ),
      ),
    );
  }
}
