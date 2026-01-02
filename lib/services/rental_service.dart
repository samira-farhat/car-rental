import 'dart:convert';
import 'package:http/http.dart' as http;


class RentalService {
   static const String baseUrl = 'http://127.0.0.1:8000/api';


  static Future<List<dynamic>> getMyRentals() async {
    final token = await AuthStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me/rentals/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rentals');
    }
  }
}
