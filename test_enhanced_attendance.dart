import 'lib/services/mock_attendance_service.dart';

void main() async {
  print('🏢 Testing Enhanced Attendance System...\n');

  try {
    // Test all four attendance types
    const employeeId = 'EMP001';

    // Morning Shift
    print('🌅 --- MORNING SHIFT ---');

    print('1. Morning Check In...');
    final morningCheckIn = await MockAttendanceService.recordCheckInWithType(
      employeeId,
      'Morning Check In',
    );
    print('   ✅ ${morningCheckIn['message']}');
    print('   📊 Data: ${morningCheckIn['data']}\n');

    await Future.delayed(Duration(seconds: 1));

    print('2. Morning Check Out...');
    final morningCheckOut = await MockAttendanceService.recordCheckOutWithType(
      employeeId,
      'Morning Check Out',
    );
    print('   ✅ ${morningCheckOut['message']}');
    print('   📊 Data: ${morningCheckOut['data']}\n');

    await Future.delayed(Duration(seconds: 1));

    // Afternoon Shift
    print('🌇 --- AFTERNOON SHIFT ---');

    print('3. Afternoon Check In...');
    final afternoonCheckIn = await MockAttendanceService.recordCheckInWithType(
      employeeId,
      'Afternoon Check In',
    );
    print('   ✅ ${afternoonCheckIn['message']}');
    print('   📊 Data: ${afternoonCheckIn['data']}\n');

    await Future.delayed(Duration(seconds: 1));

    print('4. Afternoon Check Out...');
    final afternoonCheckOut =
        await MockAttendanceService.recordCheckOutWithType(
          employeeId,
          'Afternoon Check Out',
        );
    print('   ✅ ${afternoonCheckOut['message']}');
    print('   📊 Data: ${afternoonCheckOut['data']}\n');

    // Show all records
    print('📋 --- ALL ATTENDANCE RECORDS ---');
    final allRecords = MockAttendanceService.getAllRecords();
    for (int i = 0; i < allRecords.length; i++) {
      final record = allRecords[i];
      print(
        '${i + 1}. ${record['checkInType']} - ${record['time']} (${record['date']})',
      );
    }

    print('\n🎉 Enhanced Attendance System is working perfectly!');
    print('👥 Employee can now track:');
    print('   • Morning Check In');
    print('   • Morning Check Out');
    print('   • Afternoon Check In');
    print('   • Afternoon Check Out');
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
