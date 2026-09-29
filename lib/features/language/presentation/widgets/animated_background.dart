import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
            ),
          ),
        ),

        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: .08),
            ),
          ),
        ),

        Positioned(
          bottom: -140,
          left: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: .06),
            ),
          ),
        ),

        Positioned(
          top: 70,
          left: 30,
          child: Icon(
            Icons.shield_outlined,
            size: 70,
            color: Colors.blue.withValues(alpha: .06),
          ),
        ),

        Positioned(
          top: 80,
          right: 35,
          child: Icon(
            Icons.lock_outline,
            size: 60,
            color: Colors.blue.withValues(alpha: .06),
          ),
        ),

        Positioned(
          bottom: 60,
          left: 20,
          child: Icon(
            Icons.fingerprint,
            size: 80,
            color: Colors.blue.withValues(alpha: .05),
          ),
        ),

        Positioned(
          bottom: 40,
          right: 20,
          child: Icon(
            Icons.verified_user_outlined,
            size: 75,
            color: Colors.blue.withValues(alpha: .05),
          ),
        ),
      ],
    );
  }
}
