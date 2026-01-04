import 'package:car_management_frontend/main_screens/bottom_nav_screen.dart';
import 'package:car_management_frontend/screens/auth/verify_account_screen.dart';
import 'package:car_management_frontend/screens/customer_screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'main_screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // restore jwt token on app start
  SharedPreferences prefs = await SharedPreferences.getInstance();
  authToken = prefs.getString('access');

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drive With Khachab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/bottom_nav': (context) => BottomNavScreen(),
        '/payment': (context) => PaymentScreen(),
        '/verify': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return VerifyAccountScreen(
            email: args['email']!,
            password: args['password']!, // <-- pass the password
          );
        },
      },
    );
  }
}
