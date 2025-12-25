import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../screens/customer_screens/rent_screen.dart';
import '../screens/customer_screens/reserve_screen.dart';
import '../globals.dart'; // importing the global wishlistred cars list

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
  bool isWishlisted = false; // heart state

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

                // Wishlist Heart Icon
                IconButton(
                  onPressed: () {
                    if (widget.isGuest) {
                      Navigator.pushNamed(context, '/login'); // go to login for guests
                    } else {
                      setState(() {
                        isWishlisted = !isWishlisted;

                        if (isWishlisted) {
                          wishlistedCars.add(widget.car.carId);
                        } else {
                          wishlistedCars.remove(widget.car.carId);
                        }

                        print('Current wishlist: $wishlistedCars');
                      });
                    }
                  },
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
