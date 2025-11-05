import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/test_connection_page.dart';
import 'pages/splash_page.dart';
import 'pages/network_guard_page.dart';
import 'pages/network_debug_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chol Smart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/test': (context) => const TestConnectionPage(),
        '/network-guard': (context) => const NetworkGuardPage(),
        '/network-debug': (context) => const NetworkDebugPage(),
      },
    );
  }
}
