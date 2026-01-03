import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';

class DocumentService {
  static const String baseUrl = 'http://localhost:8000/api/documents/';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// ==============================
  /// GET MY DOCUMENTS
  /// ==============================
  static Future<List<dynamic>> getMyDocuments() async {
    final token = await _storage.read(key: 'access');

    final response = await http.get(
      Uri.parse('${baseUrl}my/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load documents');
    }
  }

  /// ==============================
  /// UPLOAD DOCUMENT (MULTIPART)
  /// ==============================
  static Future<void> uploadDocument({
    required File file,
    required String documentType,
  }) async {
    final token = await _storage.read(key: 'access');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${baseUrl}upload/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Add document type
    request.fields['document_type'] = documentType;

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(
        'document_image',
        file.path,
        filename: basename(file.path),
      ),
    );

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Document upload failed');
    }
  }
}
