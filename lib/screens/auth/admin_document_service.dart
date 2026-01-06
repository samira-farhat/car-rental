import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminDocumentService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String baseUrl =
      'http://localhost:8000/api/admin/documents/';

  static Future<List<dynamic>> getAllDocuments() async {
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
      throw Exception('Failed to fetch documents');
    }
  }

  static Future<void> updateDocumentStatus(
      int documentId, String status) async {
    final token = await _storage.read(key: 'access');

    final response = await http.post(
      Uri.parse('$baseUrl$documentId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update document');
    }
  }
}
