import 'package:http/http.dart' as http;
import 'dart:io';

class GoogleSheetsService {
  static const String _baseUrl = 'https://docs.google.com/spreadsheets/d';
  static const String _sheetId = '1NFDdOPiwTuQGm-QUAbJk4akdhR-SciIj1hpGQ6yoqP0';
  static const String _gid = '0';

  // This uses the CSV export endpoint which doesn't require authentication
  // Format: https://docs.google.com/spreadsheets/d/{sheetId}/export?format=csv&gid={gid}
  static String get _csvUrl =>
      '$_baseUrl/$_sheetId/export?format=csv&gid=$_gid';

  static Future<List<Map<String, dynamic>>> getEmployeeData() async {
    try {
      final response = await http.get(
        Uri.parse(_csvUrl),
        headers: {
          'User-Agent': 'CholSmart/1.0 (Flutter Mobile App)',
          'Accept': 'text/csv,application/csv,text/plain',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final csvData = response.body;
        return _parseCsvData(csvData);
      } else {
        throw Exception(
          'Failed to load employee data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('GoogleSheetsService Error: $e');
      throw Exception('Error fetching employee data: $e');
    }
  }

  static List<Map<String, dynamic>> _parseCsvData(String csvData) {
    final lines = csvData.split('\n');
    if (lines.isEmpty) return [];

    // Get headers from first line
    final headers = lines[0]
        .split(',')
        .map((h) => h.trim().replaceAll('"', ''))
        .toList();

    final employees = <Map<String, dynamic>>[];

    // Process data rows (skip header)
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = line
          .split(',')
          .map((v) => v.trim().replaceAll('"', ''))
          .toList();

      if (values.length >= headers.length) {
        final employee = <String, dynamic>{};
        for (int j = 0; j < headers.length; j++) {
          employee[headers[j]] = values[j];
        }
        employees.add(employee);
      }
    }

    return employees;
  }

  static Future<Map<String, dynamic>?> authenticateEmployee(
    String employeeId,
    String password,
  ) async {
    try {
      final employees = await getEmployeeData();

      // Find employee with matching ID and password
      for (final employee in employees) {
        final id = employee['Employee ID']?.toString() ?? '';
        final pass = employee['Password']?.toString() ?? '';

        if (id == employeeId && pass == password) {
          return employee;
        }
      }

      return null; // No matching employee found
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }
}
