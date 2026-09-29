import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/localization/app_text.dart';

class CyberHealthScoreCard extends StatelessWidget {
  const CyberHealthScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    const score = 92;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ============================================================
          // SCORE CIRCLE
          // ============================================================
          SizedBox(
            width: 92,
            height: 92,
            child: CustomPaint(
              painter: _ScorePainter(progress: score / 100),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '$score%',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff16A34A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      AppText.t(context, "Healthy"),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ============================================================
          // CONTENT
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        AppText.t(context, "Phone Health Score"),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff111827),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xffDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 13,
                        color: Color(0xff16A34A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  AppText.t(context, "Excellent"),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff16A34A),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  AppText.t(context, "Your phone is protected."),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ============================================================
          // RIGHT SHIELD
          // ============================================================
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffECFDF3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xff22A653),
              size: 27,
            ),
          ),

          const SizedBox(width: 3),

          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xff94A3B8),
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// SCORE RING
// ========================================================================

class _ScorePainter extends CustomPainter {
  final double progress;

  const _ScorePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = (size.width / 2) - 5;

    final backgroundPaint = Paint()
      ..color = const Color(0xffE8F5EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = const Color(0xff20A852)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScorePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
