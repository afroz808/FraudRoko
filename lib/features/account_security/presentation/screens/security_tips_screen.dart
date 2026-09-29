import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'security_tip_detail_screen.dart';

class SecurityTipsScreen extends StatelessWidget {
  const SecurityTipsScreen({super.key});

  String _language(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  String _title(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'अकाउंट सुरक्षित ठेवा';
      case 'en':
        return 'Secure Your Accounts';
      default:
        return 'अकाउंट सुरक्षित रखें';
    }
  }

  String _emptyText(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'सध्या कोणतीही माहिती उपलब्ध नाही.';
      case 'en':
        return 'No account security information available yet.';
      default:
        return 'अभी अकाउंट सुरक्षा की जानकारी उपलब्ध नहीं है।';
    }
  }

  String _value(Map<String, dynamic> data, String type, String language) {
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

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _title(context),
          style: const TextStyle(
            color: Color(0xff111827),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('security_tips')
            .where('published', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load security information.'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  _emptyText(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff667085),
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final title = _value(data, 'title', language);
              final content = _value(data, 'content', language);
              final imageUrl = data['imageUrl']?.toString().trim() ?? '';
              final category = data['category']?.toString().trim() ?? '';

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SecurityTipDetailScreen(
                          data: data,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 78,
                                  height: 78,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _placeholderImage(),
                                )
                              : _placeholderImage(),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (category.isNotEmpty)
                                Text(
                                  category.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xff667085),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .5,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                title.isEmpty ? 'Untitled' : title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff111827),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (content.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xff667085),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xff98A2B3),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 78,
      height: 78,
      color: const Color(0xffEAF4FF),
      alignment: Alignment.center,
      child: const Icon(
        Icons.security_rounded,
        color: Color(0xff1565FF),
        size: 30,
      ),
    );
  }
}
