import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../globals.dart';
import '../../models/car_model.dart';
import '../../widgets/car_card.dart';
import 'car_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowseScreen extends StatefulWidget {
  final bool isGuest;

  const BrowseScreen({
    super.key,
    required this.isGuest,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final Color midnightBlue = Color(0xFF004760);

  List<Car> cars = [];
  List<String> categories = ["All"];
  String selectedCategory = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarsAndWishlist();
  }

  // Fetch cars and wishlist sequentially
  Future<void> fetchCarsAndWishlist() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    // Clear wishlist if guest
    if (widget.isGuest) {
      wishlistedCarsNotifier.value = [];
    }

    final url = Uri.parse('http://localhost:8000/api/cars/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        List<Car> fetchedCars = data.map((e) => Car.fromJson(e)).toList();
        globalCars = fetchedCars;

        // extract categories dynamically
        Set<String> catSet = fetchedCars.map((c) => c.categoryName).toSet();
        List<String> catList = ["All"];
        catList.addAll(catSet);

        cars = fetchedCars;
        categories = catList;

        // Fetch wishlist **before building UI**
        if (!widget.isGuest && token != null) {
          await fetchWishlist(token);
        }

        // Now rebuild the UI with cars and wishlist ready
        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to fetch cars: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch wishlist from backend and update notifier
  Future<void> fetchWishlist(String token) async {
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
      List<int> wishlistedIds =
      data.map<int>((item) => item['car']['id'] as int).toList();
      wishlistedCarsNotifier.value = wishlistedIds;
    } else {
      print('Failed to fetch wishlist: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // filter cars based on selected category
    List<Car> displayedCars = selectedCategory == "All"
        ? cars
        : cars.where((c) => c.categoryName == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Your Next Drive Starts Here...",
          style: TextStyle(
            fontFamily: "Times New Roman",
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // categories row
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  bool isSelected = category == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                        isSelected ? midnightBlue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // cars list
            Expanded(
              child: displayedCars.isEmpty
                  ? Center(child: Text("No cars available"))
                  : ValueListenableBuilder<List<int>>(
                valueListenable: wishlistedCarsNotifier,
                builder: (context, wishlisted, _) {
                  // rebuilds whenever wishlist changes
                  return ListView.builder(
                    itemCount: displayedCars.length,
                    itemBuilder: (context, index) {
                      return CarCard(
                        car: displayedCars[index],
                        isGuest: widget.isGuest,
                        onTap: () {
                          if (widget.isGuest) {
                            Navigator.pushNamed(context, '/login');
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetailsScreen(
                                    car: displayedCars[index]),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
