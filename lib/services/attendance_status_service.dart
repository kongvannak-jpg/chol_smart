import 'package:shared_preferences/shared_preferences.dart';

class AttendanceStatusService {
  static const String _morningCheckInKey = 'morning_check_in_';
  static const String _morningCheckOutKey = 'morning_check_out_';
  static const String _afternoonCheckInKey = 'afternoon_check_in_';
  static const String _afternoonCheckOutKey = 'afternoon_check_out_';
  static const String _lastDateKey = 'last_attendance_date_';

  /// Get today's date string (YYYY-MM-DD)
  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get the storage key for an employee and attendance type
  static String _getKey(String employeeId, String attendanceType) {
    final today = _getTodayDateString();
    switch (attendanceType) {
      case 'Morning Check In':
        return '$_morningCheckInKey$employeeId\_$today';
      case 'Morning Check Out':
        return '$_morningCheckOutKey$employeeId\_$today';
      case 'Afternoon Check In':
        return '$_afternoonCheckInKey$employeeId\_$today';
      case 'Afternoon Check Out':
        return '$_afternoonCheckOutKey$employeeId\_$today';
      default:
        return '${attendanceType.replaceAll(' ', '_').toLowerCase()}_$employeeId\_$today';
    }
  }

  /// Check if an attendance type is already completed today
  static Future<bool> isAttendanceCompleted(
    String employeeId,
    String attendanceType,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(employeeId, attendanceType);
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('Error checking attendance status: $e');
      return false;
    }
  }

  /// Mark an attendance type as completed
  static Future<void> markAttendanceCompleted(
    String employeeId,
    String attendanceType,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(employeeId, attendanceType);
      await prefs.setBool(key, true);

      // Also update the last attendance date
      final lastDateKey = '$_lastDateKey$employeeId';
      await prefs.setString(lastDateKey, _getTodayDateString());

      print('Marked attendance completed: $attendanceType for $employeeId');
    } catch (e) {
      print('Error marking attendance completed: $e');
    }
  }

  /// Get all attendance statuses for today
  static Future<Map<String, bool>> getTodayAttendanceStatus(
    String employeeId,
  ) async {
    final attendanceTypes = [
      'Morning Check In',
      'Morning Check Out',
      'Afternoon Check In',
      'Afternoon Check Out',
    ];

    final status = <String, bool>{};

    for (final type in attendanceTypes) {
      status[type] = await isAttendanceCompleted(employeeId, type);
    }

    return status;
  }

  /// Clear attendance data for testing (optional)
  static Future<void> clearTodayAttendance(String employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attendanceTypes = [
        'Morning Check In',
        'Morning Check Out',
        'Afternoon Check In',
        'Afternoon Check Out',
      ];

      for (final type in attendanceTypes) {
        final key = _getKey(employeeId, type);
        await prefs.remove(key);
      }

      print('Cleared today attendance for $employeeId');
    } catch (e) {
      print('Error clearing attendance: $e');
    }
  }

  /// Clean up old attendance records (keep only last 30 days)
  static Future<void> cleanupOldRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      for (final key in keys) {
        if (key.contains('_check_in_') || key.contains('_check_out_')) {
          // Extract date from key (format: type_employeeId_YYYY-MM-DD)
          final parts = key.split('_');
          if (parts.length >= 3) {
            final dateStr = parts.last;
            try {
              final recordDate = DateTime.parse(dateStr);
              if (recordDate.isBefore(cutoffDate)) {
                await prefs.remove(key);
              }
            } catch (e) {
              // Invalid date format, remove the key
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old records: $e');
    }
  }

  /// Check if user can check out (must check in first)
  static Future<bool> canCheckOut(String employeeId, String period) async {
    if (period == 'Morning') {
      return await isAttendanceCompleted(employeeId, 'Morning Check In');
    } else if (period == 'Afternoon') {
      return await isAttendanceCompleted(employeeId, 'Afternoon Check In');
    }
    return false;
  }
}
