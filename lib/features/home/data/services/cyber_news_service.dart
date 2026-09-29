import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cyber_news_model.dart';

class CyberNewsService {
  CyberNewsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _newsCollection =>
      _firestore.collection('cyber_news');

  Stream<List<CyberNewsModel>> watchLatestNews() {
    return _newsCollection
        .orderBy('publishedAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(CyberNewsModel.fromFirestore).toList(),
        );
  }

  Future<List<CyberNewsModel>> getLatestNews() async {
    final snapshot = await _newsCollection
        .orderBy('publishedAt', descending: true)
        .limit(30)
        .get();

    return snapshot.docs.map(CyberNewsModel.fromFirestore).toList();
  }

  Future<void> addNews(CyberNewsModel news) async {
    await _newsCollection.doc(news.id).set(news.toFirestore());
  }

  Future<void> deleteNews(String newsId) async {
    await _newsCollection.doc(newsId).delete();
  }
}
