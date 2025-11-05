import 'dart:convert';

class MockAttendanceService {
  static final List<Map<String, dynamic>> _attendanceRecords = [];

  static Future<Map<String, dynamic>> recordCheckIn(String employeeId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final record = {
      'employeeId': employeeId,
      'checkInType': 'Check In',
      'timestamp': now.millisecondsSinceEpoch,
      'date': now.toIso8601String().split('T')[0],
      'time':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    };

    _attendanceRecords.add(record);

    print('Mock Check-in recorded: ${json.encode(record)}');

    return {
      'success': true,
      'message': 'Check-in recorded successfully',
      'data': record,
    };
  }

  static Future<Map<String, dynamic>> recordCheckOut(String employeeId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final record = {
      'employeeId': employeeId,
      'checkInType': 'Check Out',
      'timestamp': now.millisecondsSinceEpoch,
      'date': now.toIso8601String().split('T')[0],
      'time':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    };

    _attendanceRecords.add(record);

    print('Mock Check-out recorded: ${json.encode(record)}');

    return {
      'success': true,
      'message': 'Check-out recorded successfully',
      'data': record,
    };
  }

  // New methods for specific attendance types
  static Future<Map<String, dynamic>> recordCheckInWithType(
    String employeeId,
    String attendanceType,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final record = {
      'employeeId': employeeId,
      'checkInType': attendanceType,
      'timestamp': now.millisecondsSinceEpoch,
      'date': now.toIso8601String().split('T')[0],
      'time':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    };

    _attendanceRecords.add(record);

    print('Mock $attendanceType recorded: ${json.encode(record)}');

    return {
      'success': true,
      'message': '$attendanceType recorded successfully',
      'data': record,
    };
  }

  static Future<Map<String, dynamic>> recordCheckOutWithType(
    String employeeId,
    String attendanceType,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final record = {
      'employeeId': employeeId,
      'checkInType': attendanceType,
      'timestamp': now.millisecondsSinceEpoch,
      'date': now.toIso8601String().split('T')[0],
      'time':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
    };

    _attendanceRecords.add(record);

    print('Mock $attendanceType recorded: ${json.encode(record)}');

    return {
      'success': true,
      'message': '$attendanceType recorded successfully',
      'data': record,
    };
  }

  static List<Map<String, dynamic>> getAllRecords() {
    return List.from(_attendanceRecords);
  }

  static void clearRecords() {
    _attendanceRecords.clear();
  }
}
