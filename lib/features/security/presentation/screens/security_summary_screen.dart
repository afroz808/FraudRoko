import 'package:fraudroko_app/features/security/presentation/security_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_text.dart';

class SecuritySummaryScreen extends StatelessWidget {
  const SecuritySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      appBar: AppBar(
        title: Text(AppText.t(context, "Phone Security")),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xffEEF7FF),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Color(0xff1565FF),
                      size: 70,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      AppText.t(context, "Phone Health Score"),
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "92",
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1565FF),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      AppText.t(context, "Your phone looks safe."),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.apps,
                      AppText.t(context, "Apps"),
                      "184",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _infoCard(
                      Icons.warning_amber_rounded,
                      AppText.t(context, "Risks"),
                      "2",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.check_circle,
                      AppText.t(context, "Checks"),
                      "8",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _infoCard(
                      Icons.schedule,
                      AppText.t(context, "Last Scan"),
                      "Now",
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecurityScreen()),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1565FF),
                    foregroundColor: Colors.white,
                  ),

                  child: Text(AppText.t(context, "View Full Report")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: const Color(0xff1565FF)),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
