import 'package:flutter/material.dart';

class SplashLoader extends StatelessWidget {
  const SplashLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 180,
      child: LinearProgressIndicator(
        minHeight: 5,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}
