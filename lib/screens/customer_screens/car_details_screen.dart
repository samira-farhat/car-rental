import 'package:car_management_frontend/screens/customer_screens/reserve_screen.dart';
import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../globals.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../widgets/review_card.dart';

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

  List reviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/api/reviews/car/${widget.car.carId}/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          reviews = json.decode(response.body);
          isLoadingReviews = false;
        });
      } else {
        setState(() => isLoadingReviews = false);
      }
    } catch (_) {
      setState(() => isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),

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

                  Text(
                    '${widget.car.brand} ${widget.car.model}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: midnightBlue,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    '${widget.car.year} • ${widget.car.categoryName}',
                    style: TextStyle(fontSize: 16, color: midnightBlue),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '\$${widget.car.rentalPricePerDay} / day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: midnightBlue,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    widget.car.availabilityStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.car.availabilityStatus.toUpperCase() ==
                          "AVAILABLE"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(
                    widget.car.description ?? 'No description available',
                    style: TextStyle(fontSize: 14),
                  ),

                  SizedBox(height: 32),

                  // buttons
                  Row(
                    children: [

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

                      ValueListenableBuilder<List<int>>(
                        valueListenable: wishlistedCarsNotifier,
                        builder: (context, wishlisted, child) {
                          final isWishlisted =
                          wishlisted.contains(widget.car.carId);

                          return IconButton(
                            iconSize: 32,
                            icon: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isWishlisted ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              final storage =
                              const FlutterSecureStorage();
                              final token =
                              await storage.read(key: 'access');

                              if (isWishlisted) {
                                wishlistedCarsNotifier.value =
                                List.from(wishlisted)
                                  ..remove(widget.car.carId);

                                await http.delete(
                                  Uri.parse(
                                      'http://localhost:8000/api/wishlist/${widget.car.carId}/'),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                  },
                                );
                              } else {
                                wishlistedCarsNotifier.value =
                                List.from(wishlisted)
                                  ..add(widget.car.carId);

                                await http.post(
                                  Uri.parse(
                                      'http://localhost:8000/api/wishlist/'),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(
                                      {'carid': widget.car.carId}),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 25),

                  // reviews section
                  Text(
                    'REVIEWS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: midnightBlue,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 12),

                  if (isLoadingReviews)
                    Center(child: CircularProgressIndicator()),

                  if (!isLoadingReviews && reviews.isEmpty)
                    Text(
                      'No reviews yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                  if (!isLoadingReviews)
                    ...reviews.map((review) => ReviewCard(review: review)),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
