
import 'package:flutter/material.dart';
import 'dart:async';

import 'Color/Colorclass.dart';
import 'Login/LoginNardanaScreen.dart';
import 'Login/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start animations
    _logoController.forward();

    // Delay fade animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });

    // Navigate to admin dashboard after delay
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5B9BD5),
              Color(0xFF3A7BC8),
              Color(0xFF2E5C8A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            _buildAnimatedCircles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 40 : 30),
                      // decoration: BoxDecoration(
                      //   color: Colors.transparent,
                      //   shape: BoxShape.circle,
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withOpacity(0.2),
                      //       blurRadius: 30,
                      //       spreadRadius: 5,
                      //       offset: const Offset(0, 10),
                      //     ),
                      //   ],
                      // ),
                      child: Image.asset(
                        'assets/images/CongoLogo.png',
                        height: isTablet ? 120 : 100,
                        width: isTablet ? 120 : 100,
                        fit: BoxFit.contain,
                        // Fallback if image doesn't load
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            size: isTablet ? 120 : 100,
                            color: const Color(0xFF5B9BD5),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 50 : 40),

                  // App name with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        Text(
                          'INNOWEAVE',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 60 : 50),

                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLoadingIndicator(isTablet),
                  ),
                ],
              ),
            ),

            // Version text at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 40,
          child: CircularProgressIndicator(
            color: C.appBar3,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isTablet ? 16 : 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
