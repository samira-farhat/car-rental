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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    final url = Uri.parse("http://192.168.0.110:8000/api/cars/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      setState(() {
        cars = data.map((e) => Car.fromJson(e)).toList();
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
        child: ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            return CarCard(
              car: cars[index],
              isGuest: widget.isGuest,
              onTap: () {
                if (widget.isGuest) {
                  // if user is a guest → go to login
                  Navigator.pushNamed(context, '/login');
                } else{
                  // logged in → go to view car details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(car: cars[index]),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
