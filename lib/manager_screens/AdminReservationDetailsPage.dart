import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../globals.dart';

class AdminReservationDetailsPage extends StatefulWidget {
  final int reservationId;

  const AdminReservationDetailsPage({
    super.key,
    required this.reservationId,
  });

  @override
  State<AdminReservationDetailsPage> createState() =>
      _AdminReservationDetailsPageState();
}

class _AdminReservationDetailsPageState
    extends State<AdminReservationDetailsPage> {
  final storage = const FlutterSecureStorage();

  bool isLoading = true;
  Map<String, dynamic>? reservation;

  @override
  void initState() {
    super.initState();
    fetchReservationDetails();
  }

  Future<void> fetchReservationDetails() async {
    final token = await storage.read(key: 'access_token');

    final response = await http.get(
      Uri.parse(
        'http://localhost:8000/api/admin/reservations/${widget.reservationId}/',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reservation = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load reservation details');
    }
  }

  Future<void> approveReservation() async {
    await adminAction('approve');
  }

  Future<void> rejectReservation() async {
    await adminAction('reject');
  }

  Future<void> adminAction(String action) async {
    final token = await storage.read(key: 'access_token');

    final response = await http.post(
      Uri.parse(
        'http://localhost:8000/api/admin/reservations/${widget.reservationId}/$action/',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      fetchReservationDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final r = reservation!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Reservation'),
            infoRow('ID', r['id'].toString()),
            infoRow('Status', r['status']),
            infoRow('Created At', r['created_at']),

            const Divider(height: 32),

            sectionTitle('User'),
            infoRow('Name', r['user']['full_name']),
            infoRow('Phone', r['user']['phone']),
            infoRow('Email', r['user']['email']),

            const Divider(height: 32),

            sectionTitle('Car'),
            Image.network(
              'http://localhost:8000/media/${r['car']['image']}',
              height: 180,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            infoRow(
              'Car',
              '${r['car']['brand']} ${r['car']['model']} (${r['car']['year']})',
            ),
            infoRow('Price / day', '\$${r['car']['price_per_day']}'),

            const Divider(height: 32),

            sectionTitle('Dates & Pricing'),
            infoRow('Start Date', r['start_date']),
            infoRow('End Date', r['end_date']),
            infoRow('Duration', '${r['duration']} days'),
            infoRow('Total Price', '\$${r['total_price']}'),

            const SizedBox(height: 32),

            if (r['status'] == 'pending') adminActions(),
          ],
        ),
      ),
    );
  }

  Widget adminActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: approveReservation,
            child: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: rejectReservation,
            child: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
