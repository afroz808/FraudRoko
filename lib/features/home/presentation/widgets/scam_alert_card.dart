import 'package:flutter/material.dart';

import '../../data/models/cyber_news_model.dart';
import '../../data/services/cyber_news_service.dart';
import '../screens/cyber_news_screen.dart';

class ScamAlertCard extends StatelessWidget {
  const ScamAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CyberNewsModel>>(
      stream: CyberNewsService().watchLatestNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }

        if (snapshot.hasError) {
          return const _EmptyCard();
        }

        final news = snapshot.data ?? [];

        if (news.isEmpty) {
          return const _EmptyCard();
        }

        final latestNews = news.first;
        final language = Localizations.localeOf(context).languageCode;

        return _NewsAlertCard(news: latestNews, language: language);
      },
    );
  }
}

class _NewsAlertCard extends StatelessWidget {
  final CyberNewsModel news;
  final String language;

  const _NewsAlertCard({required this.news, required this.language});

  String get title {
    switch (language) {
      case 'mr':
        return news.titleMr.isNotEmpty ? news.titleMr : news.titleEn;
      case 'en':
        return news.titleEn;
      default:
        return news.titleHi.isNotEmpty ? news.titleHi : news.titleEn;
    }
  }

  String get summary {
    switch (language) {
      case 'mr':
        return news.summaryMr.isNotEmpty ? news.summaryMr : news.summaryEn;
      case 'en':
        return news.summaryEn;
      default:
        return news.summaryHi.isNotEmpty ? news.summaryHi : news.summaryEn;
    }
  }

  String get alertTitle {
    switch (language) {
      case 'mr':
        return 'आजचा सायबर अलर्ट';
      case 'en':
        return 'Today’s Cyber Alert';
      default:
        return 'आज का साइबर अलर्ट';
    }
  }

  String get readText {
    switch (language) {
      case 'mr':
        return '30 सेकंदात वाचा';
      case 'en':
        return 'Read in 30 seconds';
      default:
        return '30 सेकंड में पढ़ें';
    }
  }

  void _openNews(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CyberNewsDetailScreen(news: news)),
    );
  }

  Color get accentColor {
    switch (news.category.toLowerCase()) {
      case 'upi':
      case 'payment':
        return const Color(0xffE5484D);
      case 'bank':
        return const Color(0xffB91C1C);
      case 'job':
      case 'employment':
        return const Color(0xffF59E0B);
      case 'loan':
        return const Color(0xff8B5CF6);
      case 'investment':
      case 'investment_scam':
        return const Color(0xff10B981);
      default:
        return const Color(0xff2563EB);
    }
  }

  String get categoryLabel {
    switch (language) {
      case 'mr':
        switch (news.category.toLowerCase()) {
          case 'upi':
          case 'payment':
            return 'UPI फ्रॉड';
          case 'bank':
            return 'बँक फ्रॉड';
          case 'job':
          case 'employment':
            return 'जॉब फ्रॉड';
          case 'loan':
            return 'लोन फ्रॉड';
          case 'investment':
          case 'investment_scam':
            return 'इन्व्हेस्टमेंट फ्रॉड';
          default:
            return 'सायबर अलर्ट';
        }
      case 'en':
        switch (news.category.toLowerCase()) {
          case 'upi':
          case 'payment':
            return 'UPI Scam';
          case 'bank':
            return 'Bank Fraud';
          case 'job':
          case 'employment':
            return 'Job Scam';
          case 'loan':
            return 'Loan Scam';
          case 'investment':
          case 'investment_scam':
            return 'Investment Scam';
          default:
            return 'Cyber Alert';
        }
      default:
        switch (news.category.toLowerCase()) {
          case 'upi':
          case 'payment':
            return 'UPI फ्रॉड';
          case 'bank':
            return 'बैंक फ्रॉड';
          case 'job':
          case 'employment':
            return 'जॉब फ्रॉड';
          case 'loan':
            return 'लोन फ्रॉड';
          case 'investment':
          case 'investment_scam':
            return 'इन्वेस्टमेंट फ्रॉड';
          default:
            return 'साइबर अलर्ट';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = news.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final dateText = MaterialLocalizations.of(
      context,
    ).formatMediumDate(news.publishedAt);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openNews(context),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.82)],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alertTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        categoryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 112,
                            height: 112,
                            child: hasImage
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: accentColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        child: Icon(
                                          Icons.image_not_supported_rounded,
                                          color: accentColor,
                                          size: 34,
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }

                                          return Container(
                                            color: accentColor.withValues(
                                              alpha: 0.08,
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: accentColor,
                                              ),
                                            ),
                                          );
                                        },
                                  )
                                : Container(
                                    color: accentColor.withValues(alpha: 0.08),
                                    child: Icon(
                                      Icons.article_rounded,
                                      color: accentColor,
                                      size: 36,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff111827),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                summary,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff64748B),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateText,
                            style: const TextStyle(
                              color: Color(0xff64748B),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _openNews(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentColor,
                            side: BorderSide(color: accentColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                readText,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffff1f1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffffdddd)),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xffD9303E),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;

    final title = language == 'en'
        ? 'No cyber alert yet'
        : language == 'mr'
        ? 'सध्या कोणताही सायबर अलर्ट नाही'
        : 'अभी कोई साइबर अलर्ट नहीं है';

    final subtitle = language == 'en'
        ? 'New cyber alerts will appear here.'
        : language == 'mr'
        ? 'नवीन सायबर अलर्ट येथे दिसतील.'
        : 'नई साइबर खबरें यहाँ दिखाई देंगी।';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffff1f1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffffdddd)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xffffdddd),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xffE5484D),
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xffD9303E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xff64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
