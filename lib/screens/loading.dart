// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'dart:async';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MenuScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 1000),
      ));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_CHWARA.png', width: 320),
            const SizedBox(height: 100),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 200,
                height: 4,
                color: const Color(0xFFEEEEEE),
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => FractionallySizedBox(
                    alignment: Alignment(-1.0 + (_ctrl.value * 2), 0),
                    widthFactor: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Colors.transparent, Colors.blueAccent, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("CHWARA", style: TextStyle(letterSpacing: 10, fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}