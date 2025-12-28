import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/car_model.dart';
import '../screens/customer_screens/rent_screen.dart';
import '../screens/customer_screens/reserve_screen.dart';
import '../globals.dart'; // importing the global wishlisted cars list
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CarCard extends StatefulWidget {
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
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  @override
  Widget build(BuildContext context) {
    final Color cardBlue = Color(0xFF1E83A1); // lighter midnight blue
    final Color midnightBlue = Color(0xFF004760);
    final Color snowWhite = Color(0xFFF7F9FA);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: snowWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: midnightBlue.withOpacity(0.5),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Car Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.car.imageUrl,
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
                        "${widget.car.brand} ${widget.car.model}",
                        style: TextStyle(
                          color: midnightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "${widget.car.year} • ${widget.car.categoryName}",
                        style: TextStyle(
                          color: midnightBlue,
                          fontSize: 13,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "\$${widget.car.rentalPricePerDay} / day",
                        style: TextStyle(
                          color: midnightBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rent Button
                TextButton(
                  onPressed: () {
                    if (widget.isGuest) {
                      Navigator.pushNamed(context, '/login'); // go to login for guests
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RentScreen(carId: widget.car.carId),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text('Rent'),
                ),

                // Reserve Button
                TextButton(
                  onPressed: () {
                    if (widget.isGuest) {
                      Navigator.pushNamed(context, '/login'); // go to login for guests
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReserveScreen(carId: widget.car.carId),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                  child: Text('Reserve'),
                ),

                // Wishlist Heart Icon using ValueListenableBuilder
                ValueListenableBuilder<List<int>>(
                  valueListenable: wishlistedCarsNotifier,
                  builder: (context, wishlisted, child) {
                    final isWishlisted = wishlisted.contains(widget.car.carId);

                    return IconButton(
                      onPressed: () async {
                        if (widget.isGuest) {
                          Navigator.pushNamed(context, '/login');
                        } else {
                          final storage = const FlutterSecureStorage();
                          final token = await storage.read(key: 'access');


                          if (isWishlisted) {
                            // to remove from our local notifier
                            wishlistedCarsNotifier.value =
                            List.from(wishlisted)..remove(widget.car.carId);

                            // to remove from backend
                            final url = Uri.parse(
                                'http://192.168.0.105:8000/api/wishlist/${widget.car.carId}/');
                            await http.delete(
                              url,
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer $token',
                              },
                            );

                          } else {
                            // add to local notifier
                            wishlistedCarsNotifier.value =
                            List.from(wishlisted)..add(widget.car.carId);

                            // add to backend
                            final url = Uri.parse('http://192.168.0.105:8000/api/wishlist/');
                            await http.post(
                              url,
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer $token',
                              },
                              body: jsonEncode({'carid': widget.car.carId}),
                            );

                          }
                        }
                      },
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
