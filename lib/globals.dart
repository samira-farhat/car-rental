library car_rental_globals;
import 'package:flutter/material.dart';
import 'models/car_model.dart';

// Background Gradient
Color steelBlue = Color(0xFF218BA2);
Color jetBlack =  Color(0xFF000000);
Color electricCyan = Color(0xFF49C5E0);
Color deepMidnightBlue = Color(0xFF004760);

const LinearGradient kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF000000), // Jet Black
    Color(0xFF218BA2), // Steel Blue
    Color(0xFF49C5E0), // Electric Cyan
    Color(0xFF004760), // Deep Midnight Blue
  ],
);


// Button Styles

// Common shape for primary/secondary buttons
final RoundedRectangleBorder kButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16),
);

// ElevatedButton style (login)
final ButtonStyle kElevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFFFFFFF),
  foregroundColor: const Color(0xFF000000),
  elevation: 6,
  shape: kButtonShape,
);

// OutlinedButton style (register)
final ButtonStyle kOutlinedButtonStyle = OutlinedButton.styleFrom(
  side: const BorderSide(
    color: Color(0xFFFFFFFF),
    width: 1.5,
  ),
  shape: kButtonShape,
);

// JWT token after login
String? authToken;

// all cars fetched from backend
List<Car> globalCars = [];

// Global wishlist list (stores car IDs)
ValueNotifier<List<int>> wishlistedCarsNotifier = ValueNotifier<List<int>>([]);