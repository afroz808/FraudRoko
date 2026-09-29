import 'package:flutter/material.dart';

import '../../data/models/cyber_news_model.dart';
import '../../data/services/cyber_news_service.dart';
import '../../../../core/analytics/analytics_service.dart';

class CyberNewsScreen extends StatelessWidget {
  const CyberNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffF8FAFC),
      appBar: _CyberNewsAppBar(),
      body: _CyberNewsBody(),
    );
  }
}

class _CyberNewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CyberNewsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;

    return AppBar(
      backgroundColor: const Color(0xffF8FAFC),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff111827)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _title(language),
        style: const TextStyle(
          color: Color(0xff111827),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _title(String language) {
    switch (language) {
      case 'mr':
        return 'सायबर बातम्या';
      case 'en':
        return 'Cyber News';
      default:
        return 'साइबर न्यूज़';
    }
  }
}

class _CyberNewsBody extends StatelessWidget {
  const _CyberNewsBody();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CyberNewsModel>>(
      stream: CyberNewsService().watchLatestNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff1565FF)),
          );
        }

        if (snapshot.hasError) {
          return _MessageState(
            icon: Icons.cloud_off_rounded,
            title: _errorTitle(context),
            subtitle: _errorSubtitle(context),
          );
        }

        final news = snapshot.data ?? [];

        if (news.isEmpty) {
          return _MessageState(
            icon: Icons.article_outlined,
            title: _emptyTitle(context),
            subtitle: _emptySubtitle(context),
          );
        }

        return RefreshIndicator(
          color: const Color(0xff1565FF),
          onRefresh: () async {
            await CyberNewsService().getLatestNews();
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: news.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _NewsCard(news: news[index]);
            },
          ),
        );
      },
    );
  }

  String _errorTitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'बातम्या लोड झाल्या नाहीत';
      case 'en':
        return 'Could not load news';
      default:
        return 'न्यूज़ लोड नहीं हो सकी';
    }
  }

  String _errorSubtitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.';
      case 'en':
        return 'Please try again later.';
      default:
        return 'कृपया थोड़ी देर बाद फिर कोशिश करें।';
    }
  }

  String _emptyTitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'सध्या कोणतीही बातमी नाही';
      case 'en':
        return 'No news yet';
      default:
        return 'अभी कोई न्यूज़ नहीं है';
    }
  }

  String _emptySubtitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'mr':
        return 'नवीन सायबर बातम्या येथे दिसतील.';
      case 'en':
        return 'New cyber news will appear here.';
      default:
        return 'नई साइबर न्यूज़ यहाँ दिखाई जाएगी।';
    }
  }
}

class _NewsCard extends StatelessWidget {
  final CyberNewsModel news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final title = _localizedTitle(language);
    final summary = _localizedSummary(language);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CyberNewsDetailScreen(news: news),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffE5EAF1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NewsImage(imageUrl: news.imageUrl),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.important)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _important(language),
                          style: const TextStyle(
                            color: Color(0xffDC2626),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff64748B),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${news.sourceName} • ${_formatDate(news.publishedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff94A3B8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xff94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedTitle(String language) {
    switch (language) {
      case 'mr':
        return news.titleMr.isNotEmpty ? news.titleMr : news.titleEn;
      case 'en':
        return news.titleEn;
      default:
        return news.titleHi.isNotEmpty ? news.titleHi : news.titleEn;
    }
  }

  String _localizedSummary(String language) {
    switch (language) {
      case 'mr':
        return news.summaryMr.isNotEmpty ? news.summaryMr : news.summaryEn;
      case 'en':
        return news.summaryEn;
      default:
        return news.summaryHi.isNotEmpty ? news.summaryHi : news.summaryEn;
    }
  }

  String _important(String language) {
    switch (language) {
      case 'mr':
        return 'महत्त्वाचे';
      case 'en':
        return 'IMPORTANT';
      default:
        return 'महत्वपूर्ण';
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _NewsImage extends StatelessWidget {
  final String? imageUrl;

  const _NewsImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xffEEF4FF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.article_rounded,
          color: Color(0xff1565FF),
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        imageUrl!,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 82,
            height: 82,
            color: const Color(0xffEEF4FF),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Color(0xff94A3B8),
            ),
          );
        },
      ),
    );
  }
}

class CyberNewsDetailScreen extends StatefulWidget {
  final CyberNewsModel news;

  const CyberNewsDetailScreen({super.key, required this.news});

  @override
  State<CyberNewsDetailScreen> createState() => _CyberNewsDetailScreenState();
}

class _CyberNewsDetailScreenState extends State<CyberNewsDetailScreen> {
  CyberNewsModel get news => widget.news;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logCyberNewsView(newsId: news.id);
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _detailTitle(language),
          style: const TextStyle(
            color: Color(0xff111827),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null && news.imageUrl!.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  news.imageUrl!,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 18),
            if (news.important)
              Text(
                _important(language),
                style: const TextStyle(
                  color: Color(0xffDC2626),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              _localizedTitle(language),
              style: const TextStyle(
                color: Color(0xff111827),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${news.sourceName} • ${_formatDate(news.publishedAt)}',
              style: const TextStyle(
                color: Color(0xff64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _localizedContent(language),
              style: const TextStyle(
                color: Color(0xff334155),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            if (news.sourceUrl.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                _sourceLabel(language),
                style: const TextStyle(
                  color: Color(0xff111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              SelectableText(
                news.sourceUrl,
                style: const TextStyle(color: Color(0xff1565FF), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _localizedTitle(String language) {
    switch (language) {
      case 'mr':
        return news.titleMr.isNotEmpty ? news.titleMr : news.titleEn;
      case 'en':
        return news.titleEn;
      default:
        return news.titleHi.isNotEmpty ? news.titleHi : news.titleEn;
    }
  }

  String _localizedContent(String language) {
    switch (language) {
      case 'mr':
        return news.contentMr.isNotEmpty ? news.contentMr : news.contentEn;
      case 'en':
        return news.contentEn;
      default:
        return news.contentHi.isNotEmpty ? news.contentHi : news.contentEn;
    }
  }

  String _detailTitle(String language) {
    switch (language) {
      case 'mr':
        return 'बातमी';
      case 'en':
        return 'News';
      default:
        return 'न्यूज़';
    }
  }

  String _important(String language) {
    switch (language) {
      case 'mr':
        return 'महत्त्वाचे';
      case 'en':
        return 'IMPORTANT';
      default:
        return 'महत्वपूर्ण';
    }
  }

  String _sourceLabel(String language) {
    switch (language) {
      case 'mr':
        return 'स्रोत';
      case 'en':
        return 'Source';
      default:
        return 'स्रोत';
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xffEEF4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: const Color(0xff1565FF), size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff111827),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
