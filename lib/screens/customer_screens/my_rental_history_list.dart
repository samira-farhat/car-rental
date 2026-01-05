import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'rental_details_screen.dart';

class MyRentalHistoryList extends StatefulWidget {
  const MyRentalHistoryList({super.key});

  @override
  State<MyRentalHistoryList> createState() => _MyRentalHistoryListState();
}

class _MyRentalHistoryListState extends State<MyRentalHistoryList> {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;
  List rentals = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final token = await storage.read(key: 'access');

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/rentals/me/?status=completed'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        rentals = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rentals.isEmpty) {
      return const Center(child: Text('No rental history'));
    }

    return ListView.builder(
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final r = rentals[index];
        return ListTile(
          title: Text('Rental #${r['rentalid']}'),
          subtitle: const Text('Completed'),
          trailing: const Icon(Icons.history),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RentalDetailsScreen(
                  rentalId: r['rentalid'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
