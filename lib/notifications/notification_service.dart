import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../globals.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  /// Fetch notifications for the authenticated user
  static Future<List<UserNotification>> fetchNotifications() async {
    final token = await storage.read(key: 'access');
    if (token == null) throw Exception('No access token found');

    final uri = Uri.parse('$baseUrl/notifications/user/'); // backend endpoint

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token', // pass JWT token
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      // Map JSON to UserNotification model
      return jsonList
          .map((json) => UserNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception(
          'Failed to fetch notifications. Status code: ${response.statusCode}');
    }
  }

  /// Mark a notification as read
  static Future<void> markAsRead(int notificationId) async {
    final token = await storage.read(key: 'access');
    if (token == null) throw Exception('No access token found');

    final uri = Uri.parse('$baseUrl/notifications/mark-read/$notificationId/');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Success
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception(
          'Failed to mark notification as read. Status code: ${response.statusCode}');
    }
  }
}
