import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/network_security_service.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'network_guard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    try {
      // First, check network security
      final networkResult = await NetworkSecurityService.checkNetworkSecurity();

      if (!networkResult.isAllowed) {
        // Network not allowed, show network guard page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NetworkGuardPage()),
          );
        }
        return;
      }

      // Network is authorized, check if user is already logged in
      final savedUser = await LocalStorageService.getSavedUser();

      if (mounted) {
        if (savedUser != null) {
          // User is logged in, go to home page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(employee: savedUser),
            ),
          );
        } else {
          // No saved login, go to login page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      // Error checking login status or network, go to network guard for safety
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NetworkGuardPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                'assets/icons/app_icon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Chol Smart',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Employee Management System',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),

            // Loading text
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
