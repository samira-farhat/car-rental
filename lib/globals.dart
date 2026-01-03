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

const LinearGradient kBackgroundGradientLight = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFE3F2FD), // Very Light Blue (Sky)
    Color(0xFFB3E5FC), // Light Cyan
    Color(0xFF49C5E0), // Your Electric Cyan
    Color(0xFF218BA2), // Your Steel Blue (as the darkest anchor)
  ],
  stops: [0.0, 0.4, 0.8, 1.0],
);

const LinearGradient kBackgroundGradientLight2 = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFFFFFF), // Pure White
    Color(0xFFF0F9FF), // Ice Blue
    Color(0xFF49C5E0), // Your Electric Cyan
  ],
  stops: [0.0, 0.5, 1.0],
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

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/logo.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
