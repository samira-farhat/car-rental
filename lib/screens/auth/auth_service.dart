import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> sendVerificationCode(String email) async {
  final uri = Uri.parse('http://localhost:8000/api/accounts/send-verification-code/');

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  return response.statusCode == 200;
}

Future<Map<String, dynamic>> verifyAccount({
  required String email,
  required String code,
}) async {
  final uri = Uri.parse('http://localhost:8000/api/accounts/verify-account/');

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'code': code,
    }),
  );

  final data = jsonDecode(response.body);

  return {
    'success': response.statusCode == 200,
    'message': data['message'] ?? data['error'],
  };
}
