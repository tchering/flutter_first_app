import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String tokenKey = 'auth_token';

  static bool isContractor(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    final role = userData['role']?.toString().toLowerCase();
    final position = userData['position']?.toString().toLowerCase();
    return role == 'contractor' || position == 'contractor';
  }

  static bool isSubcontractor(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    final role = userData['role']?.toString().toLowerCase();
    final position = userData['position']?.toString().toLowerCase();
    return role == 'subcontractor' || position == 'subcontractor';
  }

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

  static Future<List<dynamic>> getTasks({
    required String status,
    required bool isContractor,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final response = await http.get(
      Uri.parse('$baseUrl/tasks?status=$status&is_contractor=$isContractor'),
      headers: {
        'Authorization': formattedToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<Map<String, dynamic>> getTask(int taskId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final response = await http.get(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {
        'Authorization': formattedToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load task');
    }
  }

  static Future<void> updateTask(int taskId, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final response = await http.patch(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {
        'Authorization': formattedToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'task': data}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  static Future<List<dynamic>> getTaskApplications(int taskId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
    final url = '$baseUrl/tasks/$taskId/applications';
    print('Fetching applications from: $url');
    print('Using token: $formattedToken');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load task applications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching applications: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTaskApplication(int taskId, {int? applicationId}) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
    final url = applicationId != null 
        ? '$baseUrl/tasks/$taskId/applications/$applicationId'
        : '$baseUrl/tasks/$taskId/my_application';

    print('Fetching application from: $url');
    print('Using token: $formattedToken');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Application not found');
      } else {
        throw Exception('Failed to load task application: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching application: $e');
      rethrow;
    }
  }

  static Future<void> updateTaskApplication(int taskId, int applicationId, String status) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
    final url = '$baseUrl/tasks/$taskId/applications/$applicationId';
    
    print('Updating application at: $url');
    print('Using token: $formattedToken');
    print('Status update: $status');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'task_application': {
            'application_status': status,
          }
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update task application: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating application: $e');
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
      final uri = Uri.parse('$baseUrl/tasks/$taskId/applications');

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
      Uri.parse('$baseUrl/tasks/$taskId/applications'), // Keep plural for creating
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

  static Future<List<Task>> fetchTasksByStatus(String status) async {
    try {
      final token = await AuthService.getToken();
      final userData = await AuthService.getUserData();
      final isContractor = ApiService.isContractor(userData);
      
      // Build the URL with proper query parameters
      final queryParams = {
        'status': status,
        'position': isContractor ? 'contractor' : 'sub-contractor',
      };
      
      final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams);
      print('Fetching tasks with URI: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Tasks Response status: ${response.statusCode}');
      print('Tasks Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final tasks = data.map((json) => Task.fromJson(json)).toList();
        print('Parsed ${tasks.length} tasks');
        return tasks;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      throw Exception('Error fetching tasks: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchDepartmentsGeoJson() async {
    try {
      final response = await http.get(
        Uri.parse('https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load departments GeoJSON');
      }
    } catch (e) {
      throw Exception('Error fetching departments GeoJSON: $e');
    }
  }
}
