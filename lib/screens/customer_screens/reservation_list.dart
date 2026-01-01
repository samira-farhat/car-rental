import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/reservation_card.dart';

class MyReservationsList extends StatefulWidget {
  final String status;
  const MyReservationsList({super.key, required this.status});

  @override
  State<MyReservationsList> createState() => _MyReservationsListState();
}

class _MyReservationsListState extends State<MyReservationsList> {
  final storage = const FlutterSecureStorage();
  bool loading = true;
  List reservations = [];

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final token = await storage.read(key: 'access');

    final response = await http.get(
      Uri.parse(
        'http://localhost:8000/api/reservations/me/?status=${widget.status}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reservations = json.decode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservations.isEmpty) {
      return const Center(child: Text('No reservations found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return ReservationCard(
          reservation: reservations[index],
          onRefresh: fetchReservations,
        );
      },
    );
  }
}
