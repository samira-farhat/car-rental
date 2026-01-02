import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DocumentsService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<dynamic>> getMyDocuments() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access');

    print('DOCUMENTS TOKEN: $token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/documents/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('DOCUMENTS STATUS: ${response.statusCode}');
    print('DOCUMENTS BODY: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load documents');
    }
  }
}
