import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DashboardService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        await AuthService.logout();
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load dashboard: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
