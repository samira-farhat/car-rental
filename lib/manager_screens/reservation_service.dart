import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/reservation_model.dart';


class ReservationService {
  // Base URL of your Django backend
  static const String baseUrl = "http://localhost:8000/api/admin/reservations/";

  // Secure storage for JWT token
  static const _storage = FlutterSecureStorage();

  /// Helper method to build authorization headers
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'access');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch reservations (optionally filtered by status)
  static Future<List<Reservation>> fetchReservations(String status) async {
    final url = Uri.parse("$baseUrl?status=$status");

    final response = await http.get(
      url,
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // Convert each JSON object into a Reservation instance
      return data.map((e) => Reservation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load reservations");
    }
  }

  /// Approve a reservation
  static Future<void> approveReservation(int reservationId) async {
    final url = Uri.parse("$baseUrl$reservationId/approve/");

    final response = await http.post(
      url,
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to approve reservation");
    }
  }

  /// Reject a reservation (requires a reason)
  static Future<void> rejectReservation(
      int reservationId, String reason) async {
    final url = Uri.parse("$baseUrl$reservationId/reject/");

    final response = await http.post(
      url,
      headers: await _headers(),
      body: json.encode({'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to reject reservation");
    }
  }
}
