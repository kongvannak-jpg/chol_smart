import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleAppsScriptService {
  // Your deployed Google Apps Script Web App URL
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbyLfUH68dE0R1WF7Fy05r_iqbhJmiS4OZCtsoyJzWzU0uXgngGWuXSYK8tkwixzEMDfcw/exec';

  static Future<List<Map<String, dynamic>>> getEmployeeData() async {
    try {
      final response = await http.get(Uri.parse(_webAppUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to fetch data');
        }
      } else {
        throw Exception('Failed to load employee data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employee data: $e');
    }
  }

  static Future<Map<String, dynamic>?> authenticateEmployee(
    String employeeId,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_webAppUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'employeeId': employeeId, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          return Map<String, dynamic>.from(jsonData['data']);
        } else {
          return null; // Invalid credentials
        }
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }
}
