import 'package:cloud_firestore/cloud_firestore.dart';

class CyberNewsModel {
  final String id;
  final String titleHi;
  final String titleMr;
  final String titleEn;
  final String summaryHi;
  final String summaryMr;
  final String summaryEn;
  final String contentHi;
  final String contentMr;
  final String contentEn;
  final String sourceName;
  final String sourceUrl;
  final String category;
  final String? imageUrl;
  final DateTime publishedAt;
  final bool important;

  const CyberNewsModel({
    required this.id,
    required this.titleHi,
    required this.titleMr,
    required this.titleEn,
    required this.summaryHi,
    required this.summaryMr,
    required this.summaryEn,
    required this.contentHi,
    required this.contentMr,
    required this.contentEn,
    required this.sourceName,
    required this.sourceUrl,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    required this.important,
  });

  factory CyberNewsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return CyberNewsModel(
      id: doc.id,
      titleHi: data['titleHi']?.toString() ?? '',
      titleMr: data['titleMr']?.toString() ?? '',
      titleEn: data['titleEn']?.toString() ?? '',
      summaryHi: data['summaryHi']?.toString() ?? '',
      summaryMr: data['summaryMr']?.toString() ?? '',
      summaryEn: data['summaryEn']?.toString() ?? '',
      contentHi: data['contentHi']?.toString() ?? '',
      contentMr: data['contentMr']?.toString() ?? '',
      contentEn: data['contentEn']?.toString() ?? '',
      sourceName: data['sourceName']?.toString() ?? '',
      sourceUrl: data['sourceUrl']?.toString() ?? '',
      category: data['category']?.toString() ?? 'general',
      imageUrl: data['imageUrl']?.toString(),
      publishedAt:
          (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      important: data['important'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titleHi': titleHi,
      'titleMr': titleMr,
      'titleEn': titleEn,
      'summaryHi': summaryHi,
      'summaryMr': summaryMr,
      'summaryEn': summaryEn,
      'contentHi': contentHi,
      'contentMr': contentMr,
      'contentEn': contentEn,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
      'category': category,
      'imageUrl': imageUrl,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'important': important,
    };
  }
}
