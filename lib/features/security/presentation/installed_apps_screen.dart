import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_widget.dart';
import '../data/models/installed_app.dart';
import 'app_details_screen.dart';
import '../../../core/localization/app_text.dart';

class InstalledAppsScreen extends StatefulWidget {
  final List<InstalledApp> apps;
  const InstalledAppsScreen({
    super.key,
    required this.apps,
  });
  @override
  State<InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen>
    with SingleTickerProviderStateMixin {
  late List<InstalledApp> filteredApps;
  late AnimationController _animController;

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color bgWhite = Color(0xFFF7FAFF);

  @override
  void initState() {
    super.initState();
    filteredApps = widget.apps;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void search(String value) {
    setState(() {
      filteredApps = widget.apps.where((app) {
        final query = value.toLowerCase();
        return app.appName.toLowerCase().contains(query) ||
            app.packageName.toLowerCase().contains(query);
      }).toList();
    });
    _animController
      ..reset()
      ..forward();
  }


  @override
  Widget build(BuildContext context) {
    final totalApps = widget.apps.length;

    return Scaffold(
      backgroundColor: bgWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            centerTitle: true,
            elevation: 0,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                AppText.t(context, "Apps ({count})", {
                  "count": totalApps.toString(),
                }),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBlue, lightBlue],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Icon(
                        Icons.apps_rounded,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: search,
                    decoration: InputDecoration(
                      hintText: AppText.t(context, "ऐप खोजें"),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final app = filteredApps[index];
                final delay = (index * 60).clamp(0, 400).toDouble();

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + delay.toInt()),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: lightBlue.withValues(alpha: 0.12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppDetailsScreen(app: app),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: bgWhite,
                                ),
                                child: AppIconWidget(
                                  packageName: app.packageName,
                                  size: 52,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.appName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: app.trustedInstaller
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: app.trustedInstaller
                                                  ? Colors.green.shade200
                                                  : Colors.orange.shade200,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            app.trustedInstaller
                                                ? AppText.t(
                                                    context,
                                                    AppText.t(
                                                      context,
                                                      "🟢 प्ले स्टोर से जोड़ा गया",
                                                    ),
                                                  )
                                                : AppText.t(
                                                    context,
                                                    AppText.t(
                                                      context,
                                                      "📦 बाहर से जोड़ा गया",
                                                    ),
                                                  ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: app.trustedInstaller
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                        if (app.sensitivePermissions.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.red.shade200,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              AppText.t(
                                                context,
                                                "permissionCount",
                                                {
                                                  "count": app
                                                      .sensitivePermissions
                                                      .length
                                                      .toString(),
                                                },
                                              ),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: filteredApps.length),
            ),
          ),
        ],
      ),
    );
  }
}
