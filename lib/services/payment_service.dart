import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentService {
  static Future<Map<String, dynamic>> makePayment({
    required int reservationId,
    required String method,
  }) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access');

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/payments/make-payment/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "reservation": reservationId,
        "method": method,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw data['error'] ?? 'Payment failed';
    }
  }
}
