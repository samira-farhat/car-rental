import 'package:flutter/material.dart';
import '../../globals.dart';
import '../../models/car_model.dart';
import '../../widgets/car_card.dart';
import 'car_details_screen.dart';
import 'package:flutter/material.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color midnightBlue = Color(0xFF004760);

  String searchText = "";
  String selectedCategory = "All";
  bool availableOnly = true;

  double minPrice = 0;
  double maxPrice = 1000;

  int minYear = 2000;
  int maxYear = DateTime.now().year;

  List<String> categories = ["All"];

  @override
  void initState() {
    super.initState();

    // Extract categories dynamically
    Set<String> catSet = globalCars.map((c) => c.categoryName).toSet();
    categories = ["All"];
    categories.addAll(catSet);

    // Initialize price and year sliders
    if (globalCars.isNotEmpty) {
      final prices = globalCars
          .map((c) => double.tryParse(c.rentalPricePerDay) ?? 0)
          .toList();
      minPrice = prices.reduce((a, b) => a < b ? a : b);
      maxPrice = prices.reduce((a, b) => a > b ? a : b);

      final years = globalCars.map((c) => c.year).toList();
      minYear = years.reduce((a, b) => a < b ? a : b);
      maxYear = years.reduce((a, b) => a > b ? a : b);
    }
  }

  List<Car> get filteredCars {
    return globalCars.where((car) {
      final price = double.tryParse(car.rentalPricePerDay) ?? 0;
      final matchesSearch = searchText.isEmpty ||
          car.brand.toLowerCase().contains(searchText.toLowerCase()) ||
          car.model.toLowerCase().contains(searchText.toLowerCase());
      final matchesCategory =
          selectedCategory == "All" || car.categoryName == selectedCategory;
      final matchesPrice = price >= minPrice && price <= maxPrice;
      final matchesYear = car.year >= minYear && car.year <= maxYear;
      final matchesAvailability =
          !availableOnly || car.availabilityStatus.toLowerCase() == "available";

      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesYear &&
          matchesAvailability;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search by brand or model",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: midnightBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: midnightBlue, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),

            SizedBox(height: 12),

            // Category Chips
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            SizedBox(height: 12),

            // Filters: Price Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price per day (\$${minPrice.toInt()} - \$${maxPrice.toInt()})",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: midnightBlue),
                ),
                RangeSlider(
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  values: RangeValues(minPrice, maxPrice),
                  labels: RangeLabels(
                    minPrice.toInt().toString(),
                    maxPrice.toInt().toString(),
                  ),
                  onChanged: (values) {
                    setState(() {
                      minPrice = values.start;
                      maxPrice = values.end;
                    });
                  },
                )
              ],
            ),

            SizedBox(height: 8),

            // Filters: Year Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Year (${minYear} - ${maxYear})",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: midnightBlue),
                ),
                RangeSlider(
                  min: 2000,
                  max: DateTime.now().year.toDouble(),
                  divisions: DateTime.now().year - 2000,
                  labels: RangeLabels(minYear.toString(), maxYear.toString()),
                  values: RangeValues(minYear.toDouble(), maxYear.toDouble()),
                  onChanged: (values) {
                    setState(() {
                      minYear = values.start.toInt();
                      maxYear = values.end.toInt();
                    });
                  },
                  activeColor: midnightBlue,
                  inactiveColor: Colors.grey[300],
                ),
              ],
            ),

            SizedBox(height: 8),

            // Availability Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available only",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: midnightBlue),
                ),
                Switch(
                  value: availableOnly,
                  onChanged: (val) {
                    setState(() {
                      availableOnly = val;
                    });
                  },
                  activeColor: midnightBlue,
                ),
              ],
            ),

            SizedBox(height: 12),

            // Filtered car list
            Expanded(
              child: filteredCars.isEmpty
                  ? Center(child: Text("No cars match your filters"))
                  : ListView.builder(
                itemCount: filteredCars.length,
                itemBuilder: (context, index) {
                  return CarCard(
                    car: filteredCars[index],
                    isGuest: false, // no guest here
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarDetailsScreen(
                              car: filteredCars[index]),
                        ),
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
