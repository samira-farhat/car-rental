import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReviewService {
  static const String baseUrl = 'http://localhost:8000/api/reviews/my/';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<List<dynamic>> getMyReviews() async {
    final token = await _storage.read(key: 'access');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
