import 'package:flutter/material.dart';
import '../../models/car_model.dart';

class CarDetailsScreen extends StatelessWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Details"),
        backgroundColor: Color(0xFF004760),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Car ID: ${car.carId}"),
            Text("Brand: ${car.brand}"),
            Text("Model: ${car.model}"),
            Text("Year: ${car.year}"),
            Text("Price per day: \$${car.rentalPricePerDay}"),
            Text("Description: \$${car.description}"),
          ],
        ),
      ),
    );
  }
}
