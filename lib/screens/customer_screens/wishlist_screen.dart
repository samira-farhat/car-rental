import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../globals.dart';
import '../../models/car_model.dart';
import '../../widgets/car_card.dart';
import 'car_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access');
    if (token == null) return;

    final url = Uri.parse('http://localhost:8000/api/wishlist/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // Map JSON to Car objects
      List<Car> wishlistedCars = data.map((item) {
        Map<String, dynamic> carJson = item['car'];
        return Car.fromJson(carJson);
      }).toList();

      // Update global wishlist IDs
      wishlistedCarsNotifier.value = wishlistedCars.map((c) => c.carId).toList();

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      print("Failed to fetch wishlist: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: CustomScrollView(
        slivers: [
          // Top bar scrollable with the screen
          SliverToBoxAdapter(
            child: _buildTopBar(),
          ),

          SliverToBoxAdapter(
            child: isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(),
              ),
            )
                : ValueListenableBuilder<List<int>>(
              valueListenable: wishlistedCarsNotifier,
              builder: (context, wishlistedIds, _) {
                if (wishlistedIds.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text("No cars in your wishlist yet"),
                    ),
                  );
                }

                List<Car> displayedCars = globalCars
                    .where((c) => wishlistedIds.contains(c.carId))
                    .toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(displayedCars.length, (index) {
                      final car = displayedCars[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CarCard(
                          car: car,
                          isGuest: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CarDetailsScreen(car: car),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "YOUR WISHLIST",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Saved Cars",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Optionally navigate somewhere else if needed
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: deepMidnightBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
