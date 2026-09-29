import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _glowController;

  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _introController, curve: Curves.easeIn);

    _scale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _float = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _introController,
        _floatController,
        _glowController,
      ]),
      builder: (_, __) {
        return FadeTransition(
          opacity: _fade,
          child: Transform.translate(
            offset: Offset(0, _float.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0x330B5FFF),
                            const Color(0x660B5FFF),
                            _glowController.value,
                          )!,
                          blurRadius: 90,
                          spreadRadius: 18,
                        ),
                      ],
                    ),
                  ),
                  Hero(
                    tag: 'fraudroko_logo',
                    child: Image.asset(
                      'assets/images/fraudroko_logo.png',
                      width: 320,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
