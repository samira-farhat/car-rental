import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../globals.dart';
import 'rent_screen.dart';
import 'reserve_screen.dart';

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

                  // rent, reserve & wishlist row
                  Row(
                    children: [

                      // Rent Now button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RentScreen(carId: widget.car.carId),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: midnightBlue, width: 2),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: midnightBlue,
                          ),
                          child: Text(
                            'Rent Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Reserve button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReserveScreen(carId: widget.car.carId),
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

                      // wishlist heart icon
                      ValueListenableBuilder<List<int>>(
                        valueListenable: wishlistedCarsNotifier,
                        builder: (context, wishlisted, child) {
                          final isWishlisted =
                          wishlisted.contains(widget.car.carId);

                          return IconButton(
                            onPressed: () {
                              if (isWishlisted) {
                                wishlistedCarsNotifier.value =
                                List.from(wishlisted)
                                  ..remove(widget.car.carId);
                              } else {
                                wishlistedCarsNotifier.value =
                                List.from(wishlisted)
                                  ..add(widget.car.carId);
                              }
                            },
                            icon: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : midnightBlue,
                            ),
                            iconSize: 30,
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
