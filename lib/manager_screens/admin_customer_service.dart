import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminCustomerService {
  static const _storage = FlutterSecureStorage();
  static const baseUrl = 'http://localhost:8000/api/accounts/admin';

  static Future<List> getCustomers() async {
    final token = await _storage.read(key: 'access');
    final res = await http.get(
      Uri.parse('$baseUrl/customers/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getCustomerDetails(int id) async {
    final token = await _storage.read(key: 'access');
    final res = await http.get(
      Uri.parse('$baseUrl/customers/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(res.body);
  }

  static Future<void> updateDocument(int docId, String action) async {
    final token = await _storage.read(key: 'access');
    await http.post(
      Uri.parse('$baseUrl/verify-document/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "document_id": docId,
        "action": action
      }),
    );
  }
}
