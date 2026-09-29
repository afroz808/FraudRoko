import 'package:flutter/material.dart';

class SplashBackground extends StatefulWidget {
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  State<SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<SplashBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.15),
              radius: 1.2,
              colors: [
                Colors.white,
                Color.lerp(
                  Colors.white,
                  const Color(0xffe9f3ff),
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
