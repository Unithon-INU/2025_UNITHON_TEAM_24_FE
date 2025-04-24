// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Lottie 애니메이션 사용 시
import '../providers/auth_provider.dart';

// Add these imports if not already present
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/routes.dart'; // Import AppRoutes

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Add a delay to show splash screen
      await Future.delayed(Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        print('SplashScreen: User is logged in, navigating to home');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        print('SplashScreen: User is not logged in, navigating to login');
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      print('SplashScreen: Error during navigation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your splash screen content
            Image.asset('assets/images/logo.png', width: 200),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}