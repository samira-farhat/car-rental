import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globals.dart';
import '../../models/car_model.dart';
import '../../widgets/car_card.dart';
import '../customer_screens/car_details_screen.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) return; // no token, user not logged in

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

      // Map JSON to Car objects using globalCars as reference
      List<Car> wishlistedCars = data.map((item) {
        // backend sends full car info in 'car'
        Map<String, dynamic> carJson = item['car'];
        return Car.fromJson(carJson);
      }).toList();

      // Update global wishlist notifier with the IDs
      wishlistedCarsNotifier.value = wishlistedCars.map((c) => c.carId).toList();

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // optionally show error
      print("Failed to fetch wishlist: ${response.body}");
    }
  }

  Future<void> removeFromWishlist(int carId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token == null) return;

    final url = Uri.parse('http://localhost:8000/api/wishlist/$carId/');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      // remove locally from notifier
      wishlistedCarsNotifier.value =
      List.from(wishlistedCarsNotifier.value)..remove(carId);
    } else {
      print("Failed to remove from wishlist: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Wishlist"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<int>>(
        valueListenable: wishlistedCarsNotifier,
        builder: (context, wishlistedIds, child) {
          if (wishlistedIds.isEmpty) {
            return Center(child: Text("No cars in your wishlist yet"));
          }

          // filter globalCars to only wishlisted
          List<Car> displayedCars = globalCars
              .where((c) => wishlistedIds.contains(c.carId))
              .toList();

          return ListView.builder(
            itemCount: displayedCars.length,
            itemBuilder: (context, index) {
              final car = displayedCars[index];

              return CarCard(
                car: car,
                isGuest: false, // wishlist is only for logged-in users
                onTap: () {
                  // navigate to car details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarDetailsScreen(car: car),
                    ),
                  );
                },
                // override heart icon behavior for wishlist
                // since CarCard handles the heart via wishlistedCarsNotifier,
                // tapping it will automatically remove from wishlist
              );
            },
          );
        },
      ),
    );
  }
}
