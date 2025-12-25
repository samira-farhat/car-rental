import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final Color midnightBlue = Color(0xFF004760);

  List<Car> cars = [];
  List<String> categories = ["All"]; // will populate dynamically after fetch
  String selectedCategory = "All"; // currently selected category
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    //final url = Uri.parse("http://192.168.0.110:8000/api/cars/");
    final url = Uri.parse('http://localhost:8000/api/cars/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      List<Car> fetchedCars = data.map((e) => Car.fromJson(e)).toList();

      // extract categories from fetched cars
      Set<String> catSet = fetchedCars.map((c) => c.categoryName).toSet();
      List<String> catList = ["All"];
      catList.addAll(catSet);

      setState(() {
        cars = fetchedCars;
        categories = catList;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? midnightBlue : Colors.grey[100],
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
              child: ListView.builder(
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
                            builder: (context) => CarDetailsScreen(car: displayedCars[index]),
                          ),
                        );
                      }
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
