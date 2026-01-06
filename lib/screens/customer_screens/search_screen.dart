import 'package:flutter/material.dart';
import '../../globals.dart';
import '../../models/car_model.dart';
import '../../widgets/car_card.dart';
import 'car_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color midnightBlue = Color(0xFF004760);

  String searchText = "";
  String selectedCategory = "All";
  bool availableOnly = true;

  // Current filter values
  double minPrice = 0;
  double maxPrice = 0;

  int minYear = 0;
  int maxYear = 0;

  // Absolute bounds (from data)
  double absoluteMinPrice = 0;
  double absoluteMaxPrice = 0;

  int absoluteMinYear = 0;
  int absoluteMaxYear = 0;

  List<String> categories = ["All"];
  bool showFilters = false;

  @override
  void initState() {
    super.initState();

    // Categories
    final Set<String> catSet =
    globalCars.map((c) => c.categoryName).toSet();
    categories = ["All", ...catSet];

    if (globalCars.isNotEmpty) {
      // Prices
      final prices = globalCars
          .map((c) => double.tryParse(c.rentalPricePerDay) ?? 0)
          .toList();

      absoluteMinPrice = prices.reduce((a, b) => a < b ? a : b);
      absoluteMaxPrice = prices.reduce((a, b) => a > b ? a : b);

      minPrice = absoluteMinPrice;
      maxPrice = absoluteMaxPrice;

      // Years
      final years = globalCars.map((c) => c.year).toList();

      absoluteMinYear = years.reduce((a, b) => a < b ? a : b);
      absoluteMaxYear = years.reduce((a, b) => a > b ? a : b);

      minYear = absoluteMinYear;
      maxYear = absoluteMaxYear;
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

  void _resetFilters() {
    setState(() {
      selectedCategory = "All";
      availableOnly = true;

      minPrice = absoluteMinPrice;
      maxPrice = absoluteMaxPrice;

      minYear = absoluteMinYear;
      maxYear = absoluteMaxYear;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            // Search + filter
            SliverToBoxAdapter(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search by brand or model",
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showFilters
                              ? Icons.filter_alt_off
                              : Icons.filter_alt,
                          color: midnightBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            showFilters = !showFilters;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: midnightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(color: midnightBlue, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),
                  SizedBox(height: 12),

                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 200),
                    crossFadeState: showFilters
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildFilters(),
                    secondChild: SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Cars list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (filteredCars.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text("No cars match your filters"),
                      ),
                    );
                  }

                  return CarCard(
                    car: filteredCars[index],
                    isGuest: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CarDetailsScreen(car: filteredCars[index]),
                        ),
                      );
                    },
                  );
                },
                childCount:
                filteredCars.isEmpty ? 1 : filteredCars.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;

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
                    color: isSelected ? midnightBlue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 12),

        // Price
        Text(
          "Price per day (\$${minPrice.toInt()} - \$${maxPrice.toInt()})",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: midnightBlue),
        ),
        RangeSlider(
          min: absoluteMinPrice,
          max: absoluteMaxPrice,
          values: RangeValues(minPrice, maxPrice),
          onChanged: (values) {
            setState(() {
              minPrice = values.start;
              maxPrice = values.end;
            });
          },
        ),

        SizedBox(height: 8),

        // Year
        Text(
          "Year ($minYear - $maxYear)",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: midnightBlue),
        ),
        RangeSlider(
          min: absoluteMinYear.toDouble(),
          max: absoluteMaxYear.toDouble(),
          divisions: absoluteMaxYear - absoluteMinYear,
          values: RangeValues(
            minYear.toDouble(),
            maxYear.toDouble(),
          ),
          onChanged: (values) {
            setState(() {
              minYear = values.start.toInt();
              maxYear = values.end.toInt();
            });
          },
        ),

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
              activeColor: midnightBlue,
              onChanged: (val) {
                setState(() {
                  availableOnly = val;
                });
              },
            ),
          ],
        ),

        SizedBox(height: 10),

        Center(
          child: TextButton(
            onPressed: _resetFilters,
            child: Text(
              "Clear filters",
              style: TextStyle(
                color: midnightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
