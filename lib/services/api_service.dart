import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        await _saveToken(data['token']);
        return data;
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          // If response is not JSON, use a generic error
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
    // Convert position to match Rails validation
    if (userData['position'] == 'Contractor') {
      userData['position'] = 'contractor';
    } else if (userData['position'] == 'Sub-contractor') {
      userData['position'] = 'sub-contractor';
    }

    // Ensure establishment_date is in the correct format
    if (userData['establishment_date'] != null) {
      userData['establishment_date'] = int.parse(userData['establishment_date'].toString());
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'registration': {
            'user': userData,
          }
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        if (error['errors'] != null) {
          if (error['errors'] is List) {
            throw Exception((error['errors'] as List).join(', '));
          } else {
            throw Exception(error['errors'].toString());
          }
        } else if (error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('An unexpected error occurred');
        }
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
    final token = await getToken();
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
        await _removeToken();
      }
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Get list of years for establishment date dropdown
  static List<String> getEstablishmentYears() {
    final int currentYear = DateTime.now().year;
    return List.generate(100, (index) => (currentYear - index).toString())
      ..sort((a, b) => b.compareTo(a)); // Sort in descending order
  }

  // Get list of employee number options
  static List<Map<String, String>> getEmployeeNumberOptions() {
    return [
      {'label': '1-10', 'value': '5'},
      {'label': '11-50', 'value': '30'},
      {'label': '51-100', 'value': '75'},
      {'label': '101-500', 'value': '300'},
      {'label': '500+', 'value': '750'},
    ];
  }
}
