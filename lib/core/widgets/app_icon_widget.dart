import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../channels/app_icon_channel.dart';

class AppIconWidget extends StatefulWidget {
  final String packageName;
  final double size;

  const AppIconWidget({super.key, required this.packageName, this.size = 48});

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget> {
  Uint8List? icon;

  @override
  void initState() {
    super.initState();
    loadIcon();
  }

  Future<void> loadIcon() async {
    final data = await AppIconChannel.getAppIcon(widget.packageName);

    if (!mounted) return;

    setState(() {
      icon = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (icon == null || icon!.isEmpty) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.size / 4),
        ),
        child: const Icon(Icons.apps),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size / 4),

      child: Image.memory(
        icon!,

        width: widget.size,
        height: widget.size,

        fit: BoxFit.cover,
      ),
    );
  }
}
