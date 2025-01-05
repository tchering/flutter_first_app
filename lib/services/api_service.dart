import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../models/task.dart';

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

      print('Login Response status: ${response.statusCode}');
      print('Login Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login data: $data');
        if (data['token'] == null) {
          throw Exception('Authentication failed: No token received');
        }
        print('About to save token: ${data['token']}');
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
    const int startYear = 1900;
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

  static Future<List<Map<String, dynamic>>> fetchTasksByStatus({
    required String status, 
    bool isContractor = true
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

      print('Attempting to fetch tasks with status: $status');

      final response = await http.get(
        Uri.parse('$baseUrl/tasks?status=$status&is_contractor=${isContractor.toString()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      print('Tasks Response status: ${response.statusCode}');
      print('Tasks Response body: ${response.body}');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
        throw Exception(errorData['error'] ?? 'Failed to fetch tasks');
      }
    } catch (e) {
      print('Error in fetchTasksByStatus: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchTaskDetails({
    required int taskId
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

      print('Attempting to fetch task details for task ID: $taskId');

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      print('Task Details Response status: ${response.statusCode}');
      print('Task Details Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
        throw Exception(errorData['error'] ?? 'Failed to fetch task details');
      }
    } catch (e) {
      print('Error in fetchTaskDetails: $e');
      rethrow;
    }
  }

  static Future<List<Task>> fetchAvailableTasks({String? query}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

      final uri = Uri.parse('$baseUrl/tasks/available')
          .replace(queryParameters: query != null ? {'query': query} : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> tasksJson = data['tasks'] ?? [];
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  static Future<bool> applyForTask(int taskId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final uri = Uri.parse('$baseUrl/tasks/$taskId/task_applications');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to apply for task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error applying for task: $e');
    }
  }

  static Future<Map<String, dynamic>> getTaskApplication(int taskId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final uri = Uri.parse('$baseUrl/tasks/$taskId/task_applications');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get task application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting task application: $e');
    }
  }

  static Future<bool> deleteTaskApplication(int taskId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final uri = Uri.parse('$baseUrl/tasks/$taskId/task_applications');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': formattedToken,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete task application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task application: $e');
    }
  }

  static Future<Map<String, dynamic>> applyForTaskWithDetails({
    required int taskId,
    required double proposedPrice,
    required int experience,
    required String coverLetter,
    required String completionTimeframe,
    required String insuranceStatus,
    required String skills,
    required String equipmentOwned,
    required String paymentTerms,
    required String references,
    required bool isNegotiable,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final response = await http.post(
      Uri.parse('$baseUrl/tasks/$taskId/task_applications'), // Keep plural for creating
      headers: {
        'Content-Type': 'application/json',
        'Authorization': formattedToken,
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'task_application': {
          'proposed_price': proposedPrice,
          'experience': experience,
          'cover_letter': coverLetter,
          'completion_timeframe': completionTimeframe,
          'insurance_status': insuranceStatus,
          'skills': skills,
          'equipement_owned': equipmentOwned,
          'payment_terms': paymentTerms,
          'references': references,
          'negotiable': isNegotiable,
        },
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to apply for task: ${response.statusCode}');
    }
  }

  static Future<void> withdrawTaskApplication({required int taskId}) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId/task_application'), // Use singular for withdrawal
      headers: {
        'Content-Type': 'application/json',
        'Authorization': formattedToken,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to withdraw task application: ${response.statusCode}');
    }
  }
}
