import 'package:car_management_frontend/main_screens/bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'main_screens/home_screen.dart';


void main(){

  runApp(
    ProviderScope(
        child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){

    return MaterialApp(

      title: 'Drive With Khachab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes:{
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/bottom_nav': (context) => BottomNavScreen(),

      },
    );

  }
}