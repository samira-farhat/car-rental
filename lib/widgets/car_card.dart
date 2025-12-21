import 'package:flutter/material.dart';
import '../models/car_model.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final bool isGuest;
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.car,
    required this.isGuest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBlue = Color(0xFF1E83A1); // lighter midnight blue

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [

            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                car.imageUrl,
                width: 110,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 12),

            // Car Info
            Expanded(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${car.brand} ${car.model}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "${car.year} • ${car.categoryName}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "\$${car.rentalPricePerDay} / day",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
