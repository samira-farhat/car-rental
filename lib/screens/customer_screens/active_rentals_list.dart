import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/rental_card.dart';

class MyActiveRentalsList extends StatefulWidget {
  const MyActiveRentalsList({super.key});

  @override
  State<MyActiveRentalsList> createState() => _MyActiveRentalsListState();
}

class _MyActiveRentalsListState extends State<MyActiveRentalsList> {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;
  List rentals = [];

  @override
  void initState() {
    super.initState();
    fetchActiveRentals();
  }

  Future<void> fetchActiveRentals() async {
    final token = await storage.read(key: 'access');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/rentals/rented-cars/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        rentals = json.decode(response.body);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rentals.isEmpty) {
      return const Center(child: Text('No active rentals'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        return RentalCard(
          rental: rentals[index],
          onRefresh: fetchActiveRentals,
        );
      },
    );
  }
}
