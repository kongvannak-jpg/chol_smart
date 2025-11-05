import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceService {
  // Your deployed Google Apps Script Web App URL
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbzUv3BQZrWD0IaBgVsbq0pKzQYK6_cqOVlZla2QovPPeQH28E7cB1h4lCRzM6TszdGhRQ/exec';

  static Future<Map<String, dynamic>> checkIn(
    String employeeId,
    String checkInType,
  ) async {
    try {
      // Use GET request to avoid CORS issues with Google Apps Script
      final url = Uri.parse(
        '$_webAppUrl?action=checkIn&employeeId=$employeeId&checkInType=${Uri.encodeComponent(checkInType)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Map<String, dynamic>.from(jsonData);
      } else {
        throw Exception('Failed to record attendance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Attendance error: $e');
    }
  }

  static Future<Map<String, dynamic>> recordCheckIn(String employeeId) async {
    return await checkIn(employeeId, 'Check In');
  }

  static Future<Map<String, dynamic>> recordCheckOut(String employeeId) async {
    return await checkIn(employeeId, 'Check Out');
  }

  // New methods for specific attendance types
  static Future<Map<String, dynamic>> recordCheckInWithType(
    String employeeId,
    String attendanceType,
  ) async {
    return await checkIn(employeeId, attendanceType);
  }

  static Future<Map<String, dynamic>> recordCheckOutWithType(
    String employeeId,
    String attendanceType,
  ) async {
    return await checkIn(employeeId, attendanceType);
  }

  // Get today's attendance for an employee (for checking if already checked in)
  static Future<List<Map<String, dynamic>>> getTodayAttendance(
    String employeeId,
  ) async {
    try {
      // This would require additional API endpoint in Google Apps Script
      // For now, we'll return empty list and handle logic in the app
      return [];
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }

  // Format time for display
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Format date for display
  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }
}
