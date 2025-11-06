import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../services/local_storage_service.dart';
import '../services/network_security_service.dart';
import '../services/attendance_status_service.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> employee;
  const HomePage({super.key, required this.employee});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  Map<String, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _startNetworkMonitoring();
    _loadAttendanceStatus();
    _cleanupOldRecords();
  }

  Future<void> _loadAttendanceStatus() async {
    try {
      final employeeId = widget.employee['Employee ID']?.toString() ?? '';
      final status = await AttendanceStatusService.getTodayAttendanceStatus(
        employeeId,
      );
      setState(() {
        _attendanceStatus = status;
      });
    } catch (e) {
      print('Error loading attendance status: $e');
    }
  }

  Future<void> _cleanupOldRecords() async {
    try {
      await AttendanceStatusService.cleanupOldRecords();
    } catch (e) {
      print('Error cleaning up old records: $e');
    }
  }

  Future<void> _clearTodayAttendance() async {
    try {
      final employeeId = widget.employee['Employee ID']?.toString() ?? '';
      await AttendanceStatusService.clearTodayAttendance(employeeId);
      await _loadAttendanceStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Today\'s attendance cleared for testing'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error clearing attendance: $e');
    }
  }

  void _startNetworkMonitoring() {
    // Check network every 5 minutes
    Stream.periodic(const Duration(minutes: 5)).listen((_) async {
      if (mounted) {
        final networkResult =
            await NetworkSecurityService.checkNetworkSecurity();

        if (!networkResult.isAllowed) {
          // Network access lost, redirect to network guard
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/network-guard',
            (Route<dynamic> route) => false,
          );
        }
      }
    });
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.isNotEmpty ? name[0].toUpperCase() : 'U';
    }
  }

  Future<void> _handleAttendance(String type) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check network security before recording attendance
      final networkResult = await NetworkSecurityService.checkNetworkSecurity();

      if (!networkResult.isAllowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Network access denied: ${networkResult.reason}'),
              backgroundColor: Colors.red,
            ),
          );

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/network-guard',
            (Route<dynamic> route) => false,
          );
        }
        return;
      }

      String employeeId = widget.employee['Employee ID']?.toString() ?? '';

      Map<String, dynamic> result;
      if (type.contains('Check In')) {
        result = await AttendanceService.recordCheckInWithType(
          employeeId,
          type,
        );
      } else {
        result = await AttendanceService.recordCheckOutWithType(
          employeeId,
          type,
        );
      }

      bool success = result['success'] == true;

      if (success) {
        // Mark attendance as completed
        await AttendanceStatusService.markAttendanceCompleted(employeeId, type);
        // Reload attendance status to update UI
        await _loadAttendanceStatus();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '$type successful!' : '$type failed. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await LocalStorageService.clearUser();
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Chol Smart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAttendanceStatus,
            tooltip: 'Refresh Status',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear_today') {
                _clearTodayAttendance();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_today',
                child: Text('Clear Today\'s Attendance (Debug)'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildAttendanceSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    _getInitials(widget.employee['Name'] ?? 'User'),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employee['Name'] ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.employee['Position'] ?? 'Employee',
                        style: TextStyle(color: Colors.blue[100], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: ${widget.employee['Employee ID']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatusOverview() {
    final completedCount = _attendanceStatus.values
        .where((completed) => completed)
        .length;
    final totalCount = _attendanceStatus.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              Text(
                '$completedCount / $totalCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalCount > 0 ? completedCount / totalCount : 0,
            backgroundColor: Colors.blue[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
          if (completedCount == totalCount && totalCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  'All attendance completed for today!',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayStatusOverview(),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Time & Attendance',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Track your daily work hours',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildShiftSection(
              'Morning Shift',
              'Start your day right',
              Icons.wb_sunny,
              Colors.orange[600]!,
              [
                _buildAttendanceButton(
                  'Morning Check In',
                  Icons.login,
                  Colors.green[600]!,
                  () => _handleAttendance('Morning Check In'),
                ),
                _buildAttendanceButton(
                  'Morning Check Out',
                  Icons.logout,
                  Colors.orange[600]!,
                  () => _handleAttendance('Morning Check Out'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildShiftSection(
              'Afternoon Shift',
              'Continue your productivity',
              Icons.wb_twilight,
              Colors.blue[600]!,
              [
                _buildAttendanceButton(
                  'Afternoon Check In',
                  Icons.login,
                  Colors.blue[600]!,
                  () => _handleAttendance('Afternoon Check In'),
                ),
                _buildAttendanceButton(
                  'Afternoon Check Out',
                  Icons.logout,
                  Colors.purple[600]!,
                  () => _handleAttendance('Afternoon Check Out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftSection(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<Widget> buttons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 1, child: buttons[0]),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: buttons[1]),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    final isCompleted = _attendanceStatus[label] == true;
    final canCheckOut = label.contains('Check Out')
        ? _canCheckOut(label.contains('Morning') ? 'Morning' : 'Afternoon')
        : true;

    final isDisabled =
        isCompleted || (!canCheckOut && label.contains('Check Out'));

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(isCompleted ? Icons.check_circle : icon, size: 18),
      label: Text(
        isCompleted ? '✓ Completed' : label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted
            ? Colors.grey[400]
            : (isDisabled ? Colors.grey[300] : color),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isDisabled ? 1 : 4,
        minimumSize: const Size(140, 50),
      ),
    );
  }

  bool _canCheckOut(String period) {
    if (period == 'Morning') {
      return _attendanceStatus['Morning Check In'] == true;
    } else if (period == 'Afternoon') {
      return _attendanceStatus['Afternoon Check In'] == true;
    }
    return false;
  }
}
