import 'dart:convert';
import 'package:car_management_frontend/screens/customer_screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../globals.dart';
import '../../models/car_model.dart';
import '../../widgets/car_card.dart';
import 'car_details_screen.dart';

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
  final Color midnightBlue = const Color(0xFF004760);

  List<Car> cars = [];
  List<String> categories = ["All"];
  String selectedCategory = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarsAndWishlist();
  }

  Future<void> fetchCarsAndWishlist() async {
    setState(() {
      isLoading = true;
    });

    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access');

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

        Set<String> catSet = fetchedCars.map((c) => c.categoryName).toSet();
        categories = ["All", ...catSet];

        cars = fetchedCars;

        if (!widget.isGuest && token != null) {
          await fetchWishlist(token);
        }

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

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
      wishlistedCarsNotifier.value =
          data.map<int>((item) => item['car']['id'] as int).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Car> displayedCars = selectedCategory == "All"
        ? cars
        : cars.where((c) => c.categoryName == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        bool isSelected =
                            category == selectedCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin:
                            const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? midnightBlue
                                  : Colors.grey[100],
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cars list
                  Expanded(
                    child: displayedCars.isEmpty
                        ? const Center(
                      child: Text("No cars available"),
                    )
                        : ValueListenableBuilder<List<int>>(
                      valueListenable:
                      wishlistedCarsNotifier,
                      builder: (context, wishlisted, _) {
                        return ListView.builder(
                          itemCount:
                          displayedCars.length,
                          itemBuilder: (context, index) {
                            return CarCard(
                              car: displayedCars[index],
                              isGuest: widget.isGuest,
                              onTap: () {
                                if (widget.isGuest) {
                                  Navigator.pushNamed(
                                      context, '/login');
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CarDetailsScreen(
                                            car:
                                            displayedCars[index],
                                          ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding:
      const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
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
                "DISCOVER",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your Next Drive",
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: deepMidnightBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.favorite, // Heart icon
                color: Colors.white,
                size: 22,
              ),
            ),
          )
        ],
      ),
    );
  }
}
