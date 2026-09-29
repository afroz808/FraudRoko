import 'package:flutter/material.dart';

class SecurityTipDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const SecurityTipDetailScreen({
    super.key,
    required this.data,
  });

  String _language(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  String _value(String type, String language) {
    final keys = type == 'title'
        ? switch (language) {
            'mr' => ['titleMr', 'titleHi', 'titleEn'],
            'en' => ['titleEn', 'titleHi', 'titleMr'],
            _ => ['titleHi', 'titleMr', 'titleEn'],
          }
        : switch (language) {
            'mr' => ['contentMr', 'contentHi', 'contentEn'],
            'en' => ['contentEn', 'contentHi', 'contentMr'],
            _ => ['contentHi', 'contentMr', 'contentEn'],
          };

    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final language = _language(context);
    final title = _value('title', language);
    final content = _value('content', language);
    final imageUrl = data['imageUrl']?.toString().trim() ?? '';
    final category = data['category']?.toString().trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            if (imageUrl.isNotEmpty) const SizedBox(height: 22),
            if (category.isNotEmpty)
              Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xff667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
            const SizedBox(height: 7),
            Text(
              title.isEmpty ? 'Untitled' : title,
              style: const TextStyle(
                color: Color(0xff111827),
                fontSize: 25,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                content,
                style: const TextStyle(
                  color: Color(0xff344054),
                  fontSize: 16,
                  height: 1.65,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
