import 'package:flutter/material.dart';
import '../services/google_apps_script_service.dart';

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _result = '';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing connection...';
    });

    try {
      // Test fetching employee data
      final employees = await GoogleAppsScriptService.getEmployeeData();

      setState(() {
        _result = 'Success! Found ${employees.length} employees:\n\n';
        for (var employee in employees) {
          _result +=
              'ID: ${employee['Employee ID']}, Name: ${employee['Name']}, Position: ${employee['Position']}\n';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing login...';
    });

    try {
      // Test login with known credentials
      final employee = await GoogleAppsScriptService.authenticateEmployee(
        '1995',
        '123',
      );

      if (employee != null) {
        setState(() {
          _result = 'Login Success!\n\nEmployee Details:\n';
          employee.forEach((key, value) {
            _result += '$key: $value\n';
          });
        });
      } else {
        setState(() {
          _result = 'Login Failed: Invalid credentials';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Login Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Google Apps Script Connection'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Google Apps Script Integration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: const Text('Test Get All Employees'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: const Text('Test Login (ID: 1995, Pass: 123)'),
            ),
            const SizedBox(height: 20),

            if (_isLoading) const Center(child: CircularProgressIndicator()),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty
                        ? 'Click a button to test the connection...'
                        : _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
