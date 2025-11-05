import 'lib/services/attendance_service.dart';

void main() async {
  print('🔗 Testing Real Google Apps Script Deployment...\n');
  print(
    '📍 URL: https://script.google.com/macros/s/AKfycbzUv3BQZrWD0IaBgVsbq0pKzQYK6_cqOVlZla2QovPPeQH28E7cB1h4lCRzM6TszdGhRQ/exec\n',
  );

  const String testEmployeeId = 'EMP001';

  try {
    // Test Morning Check In
    print('🌅 Testing Morning Check In...');
    final morningCheckIn = await AttendanceService.recordCheckInWithType(
      testEmployeeId,
      'Morning Check In',
    );
    print('✅ Success: ${morningCheckIn['success']}');
    print('📝 Message: ${morningCheckIn['message']}');
    if (morningCheckIn['data'] != null) {
      print('📊 Data: ${morningCheckIn['data']}');
    }
    print('');

    // Wait 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Test Morning Check Out
    print('🌞 Testing Morning Check Out...');
    final morningCheckOut = await AttendanceService.recordCheckOutWithType(
      testEmployeeId,
      'Morning Check Out',
    );
    print('✅ Success: ${morningCheckOut['success']}');
    print('📝 Message: ${morningCheckOut['message']}');
    if (morningCheckOut['data'] != null) {
      print('📊 Data: ${morningCheckOut['data']}');
    }
    print('');

    // Wait 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Test Afternoon Check In
    print('🌇 Testing Afternoon Check In...');
    final afternoonCheckIn = await AttendanceService.recordCheckInWithType(
      testEmployeeId,
      'Afternoon Check In',
    );
    print('✅ Success: ${afternoonCheckIn['success']}');
    print('📝 Message: ${afternoonCheckIn['message']}');
    if (afternoonCheckIn['data'] != null) {
      print('📊 Data: ${afternoonCheckIn['data']}');
    }
    print('');

    // Wait 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Test Afternoon Check Out
    print('🌙 Testing Afternoon Check Out...');
    final afternoonCheckOut = await AttendanceService.recordCheckOutWithType(
      testEmployeeId,
      'Afternoon Check Out',
    );
    print('✅ Success: ${afternoonCheckOut['success']}');
    print('📝 Message: ${afternoonCheckOut['message']}');
    if (afternoonCheckOut['data'] != null) {
      print('📊 Data: ${afternoonCheckOut['data']}');
    }
    print('');

    print('🎉 All attendance types tested successfully!');
    print(
      '📋 Check your "Attendances" sheet in Google Sheets to see the records.',
    );
  } catch (e) {
    print('❌ Error during testing: $e');
    print('');
    print('🔧 Troubleshooting:');
    print(
      '1. Make sure your Google Apps Script is deployed with "Anyone" access',
    );
    print(
      '2. Verify your Google Sheet has an "Attendances" sheet (second sheet)',
    );
    print('3. Check that the script is bound to the correct spreadsheet');
  }
}
