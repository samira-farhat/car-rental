import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReturnService {
  static const _baseUrl = 'http://127.0.0.1:8000/api/returns';
  static final _storage = FlutterSecureStorage();

  // ----------------------------
  // Get pending / approved returns
  // ----------------------------
  static Future<List> fetchReturns(String status) async {
    final token = await _storage.read(key: 'access');

    final url = status == 'pending'
        ? '$_baseUrl/pending/'
        : '$_baseUrl/'; // later for history if needed

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load returns');
    }
  }

  // ----------------------------
  // Approve return (manager)
  // ----------------------------
  static Future<void> approveReturn(int returnId) async {
    final token = await _storage.read(key: 'access');

    final response = await http.post(
      Uri.parse('$_baseUrl/approve/$returnId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve return');
    }
  }
}
