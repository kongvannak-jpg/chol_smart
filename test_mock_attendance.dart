import 'lib/services/mock_attendance_service.dart';

void main() async {
  print('Testing MockAttendanceService...');

  try {
    // Test check-in
    print('\n--- Testing Check-in ---');
    final checkInResult = await MockAttendanceService.recordCheckIn('EMP001');
    print('Check-in success: ${checkInResult['success']}');
    print('Check-in message: ${checkInResult['message']}');
    print('Check-in data: ${checkInResult['data']}');

    // Wait a moment
    await Future.delayed(Duration(seconds: 1));

    // Test check-out
    print('\n--- Testing Check-out ---');
    final checkOutResult = await MockAttendanceService.recordCheckOut('EMP001');
    print('Check-out success: ${checkOutResult['success']}');
    print('Check-out message: ${checkOutResult['message']}');
    print('Check-out data: ${checkOutResult['data']}');

    // Show all records
    print('\n--- All Attendance Records ---');
    final allRecords = MockAttendanceService.getAllRecords();
    for (int i = 0; i < allRecords.length; i++) {
      print('Record ${i + 1}: ${allRecords[i]}');
    }

    print('\n✅ MockAttendanceService is working perfectly!');
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
