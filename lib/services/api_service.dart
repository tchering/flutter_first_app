import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String tokenKey = 'auth_token';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] == null) {
          throw Exception('Authentication failed: No token received');
        }
        await AuthService.saveUserData(data['user'], data['token']);
        return data;
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('An error occurred during login. Please try again.');
        }
        throw Exception(errorData['error'] ?? 'An error occurred during login');
      }
    } catch (e) {
      if (e is FormatException) {
        print('Format Exception: ${e.message}');
        throw Exception('Invalid server response format');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] == null) {
          throw Exception('Signup failed: No token received');
        }
        await AuthService.saveUserData(data['user'], data['token']);
        return data;
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('An error occurred during signup. Please try again.');
        }
        throw Exception(errorData['error'] ?? 'An error occurred during signup');
      }
    } catch (e) {
      if (e is FormatException) {
        print('Format Exception: ${e.message}');
        throw Exception('Invalid server response format');
      }
      rethrow;
    }
  }

  static Future<void> logout() async {
    final token = await AuthService.getToken();
    if (token != null) {
      try {
        await http.delete(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } finally {
        await AuthService.logout();
      }
    }
  }

  static List<String> getEstablishmentYears() {
    final int currentYear = DateTime.now().year;
    final int startYear = 1900;
    return List.generate(
      currentYear - startYear + 1,
      (index) => (currentYear - index).toString(),
    );
  }
}
