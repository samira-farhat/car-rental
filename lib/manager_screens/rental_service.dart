import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RentalService {
  static const _baseUrl = 'http://127.0.0.1:8000/api/rentals';
  static const _storage = FlutterSecureStorage();

  static Future<List<dynamic>> fetchPendingPayments() async {
    final token = await _storage.read(key: 'access');

    final response = await http.get(
      Uri.parse('$_baseUrl/pending-payments/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pending rentals');
    }
  }

  static Future<void> approvePayment(int rentalId) async {
    final token = await _storage.read(key: 'access');

    final response = await http.post(
      Uri.parse('$_baseUrl/$rentalId/approve-payment/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve payment');
    }
  }
}
