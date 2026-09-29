import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

import '../home_screen.dart';
import '../screens/profile_screen.dart';
import '../../../learning/presentation/screens/learning_screen.dart';
import '../../../security/presentation/screens/daily_security_reports_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationWidget({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    // Home
    if (index == 0) {
      if (_currentIndex != 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
      return;
    }

    // Learning
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LearningScreen()),
      );
      return;
    }

    // Reports
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DailySecurityReportsScreen()),
      );
      return;
    }

    // Profile
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
      return;
    }

    // Other tabs
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xffEAF3FF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: const Color(0xffCFE2FF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1565FF).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xff1565FF),
          unselectedItemColor: const Color(0xff64748B),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,

          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_rounded, size: 24),
              ),
              label: AppText.t(context, 'Home'),
            ),

            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.school_rounded, size: 24),
              ),
              label: AppText.t(context, 'Learn'),
            ),

            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.assessment_rounded, size: 24),
              ),
              label: AppText.t(context, 'Reports'),
            ),

            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_rounded, size: 24),
              ),
              label: AppText.t(context, 'Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
