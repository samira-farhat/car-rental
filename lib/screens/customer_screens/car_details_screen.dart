import 'package:car_management_frontend/screens/customer_screens/reserve_screen.dart';
import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../globals.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({
    super.key,
    required this.car,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final Color midnightBlue = Color(0xFF004760);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true, // back button only
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20), // top spacing

            // car image
            Image.network(
              widget.car.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // car brand & model
                  Text(
                    '${widget.car.brand} ${widget.car.model}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: midnightBlue,
                    ),
                  ),

                  SizedBox(height: 4),

                  // car year & category
                  Text(
                    '${widget.car.year} • ${widget.car.categoryName}',
                    style: TextStyle(
                      fontSize: 16,
                      color: midnightBlue,
                    ),
                  ),

                  SizedBox(height: 8),

                  // cars price per day
                  Text(
                    '\$${widget.car.rentalPricePerDay} / day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: midnightBlue,
                    ),
                  ),

                  SizedBox(height: 5),

                  // cars availability status
                  Text(
                    widget.car.availabilityStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.car.availabilityStatus.toUpperCase() == "AVAILABLE"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  SizedBox(height: 18),

                  // car description
                  Text(
                    widget.car.description ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 32),

                  // reserve & wishlist row
                  Row(
                    children: [

                      // Reserve button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReserveScreen(car: widget.car),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: midnightBlue, width: 2),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: midnightBlue,
                          ),
                          child: Text(
                            'Reserve',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Wishlist Heart
                      ValueListenableBuilder<List<int>>(
                        valueListenable: wishlistedCarsNotifier,
                        builder: (context, wishlisted, child) {
                          final isWishlisted = wishlisted.contains(widget.car.carId);

                          return IconButton(
                            iconSize: 32,
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              final storage = const FlutterSecureStorage();
                              final token = await storage.read(key: 'access');

                              if (isWishlisted) {
                                // remove locally
                                wishlistedCarsNotifier.value =
                                List.from(wishlisted)..remove(widget.car.carId);

                                // remove backend
                                final url = Uri.parse(
                                    'http://localhost:8000/api/wishlist/${widget.car.carId}/');
                                await http.delete(
                                  url,
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $token',
                                  },
                                );
                              } else {
                                // add locally
                                wishlistedCarsNotifier.value =
                                List.from(wishlisted)..add(widget.car.carId);

                                // add backend
                                final url = Uri.parse(
                                    'http://localhost:8000/api/wishlist/');
                                await http.post(
                                  url,
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $token',
                                  },
                                  body: jsonEncode({'carid': widget.car.carId}),
                                );
                              }
                            },
                          );
                        },
                      ),

                    ],
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
