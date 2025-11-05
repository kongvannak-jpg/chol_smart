import 'lib/services/attendance_service.dart';

void main() async {
  print('Testing AttendanceService...');

  try {
    // Test check-in
    print('Testing check-in...');
    final checkInResult = await AttendanceService.recordCheckIn('EMP001');
    print('Check-in result: $checkInResult');

    // Wait a moment
    await Future.delayed(Duration(seconds: 2));

    // Test check-out
    print('Testing check-out...');
    final checkOutResult = await AttendanceService.recordCheckOut('EMP001');
    print('Check-out result: $checkOutResult');
  } catch (e) {
    print('Error during testing: $e');
  }
}
