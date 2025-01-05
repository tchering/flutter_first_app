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

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

      print('Attempting to fetch profile with token: $formattedToken');

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      print('User Profile Response status: ${response.statusCode}');
      print('User Profile Response headers: ${response.headers}');
      print('User Profile Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
        throw Exception(errorData['error'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      print('Error in fetchUserProfile: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchProjectStatistics() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

      print('Attempting to fetch project statistics with token: $formattedToken');

      final response = await http.get(
        Uri.parse('$baseUrl/project_statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      print('Project Statistics Response status: ${response.statusCode}');
      print('Project Statistics Response headers: ${response.headers}');
      print('Project Statistics Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
        throw Exception(errorData['error'] ?? 'Failed to fetch project statistics');
      }
    } catch (e) {
      print('Error in fetchProjectStatistics: $e');
      rethrow;
    }
  }
}
