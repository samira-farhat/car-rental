import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data'; // ✅ REQUIRED FOR Uint8List

class DocumentService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/documents/';
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
  /// UPLOAD DOCUMENT (WEB SAFE)
  /// ==============================
  static Future<void> uploadDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String documentType,
  }) async {
    final token = await _storage.read(key: 'access');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${baseUrl}upload/'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['document_type'] = documentType;

    request.files.add(
      http.MultipartFile.fromBytes(
        'document_image',
        fileBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Upload failed: $body');
    }
  }

}