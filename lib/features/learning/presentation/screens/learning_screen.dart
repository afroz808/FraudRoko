import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../premium/data/repositories/premium_repository_impl.dart';
import '../../../premium/domain/entities/premium_status.dart';
import '../../../premium/presentation/screens/premium_purchase_screen.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('learning_content');

  String _language(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  String _title(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'शिका';
      case 'en':
        return 'Learn';
      default:
        return 'सीखें';
    }
  }

  String _subtitle(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'सायबर सुरक्षा आणि फसवणुकीपासून बचाव शिका';
      case 'en':
        return 'Learn cyber safety and protect yourself from fraud';
      default:
        return 'साइबर सुरक्षा और फ्रॉड से बचाव सीखें';
    }
  }

  String _emptyText(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'सध्या कोणतेही शिक्षण उपलब्ध नाही.';
      case 'en':
        return 'No learning content available yet.';
      default:
        return 'अभी कोई सीखने की सामग्री उपलब्ध नहीं है।';
    }
  }

  String _getContentTitle(BuildContext context, Map<String, dynamic> data) {
    final language = _language(context);

    final keys = switch (language) {
      'mr' => ['titleMr', 'titleHi', 'titleEn'],
      'en' => ['titleEn', 'titleHi', 'titleMr'],
      _ => ['titleHi', 'titleMr', 'titleEn'],
    };

    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    return 'Untitled';
  }

  String _getContentDescription(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final language = _language(context);

    final keys = switch (language) {
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

  String _typeLabel(BuildContext context, String type) {
    switch (_language(context)) {
      case 'mr':
        switch (type) {
          case 'book':
            return 'पुस्तक';
          case 'guide':
            return 'मार्गदर्शक';
          default:
            return 'कोर्स';
        }

      case 'en':
        switch (type) {
          case 'book':
            return 'Book';
          case 'guide':
            return 'Guide';
          default:
            return 'Course';
        }

      default:
        switch (type) {
          case 'book':
            return 'किताब';
          case 'guide':
            return 'गाइड';
          default:
            return 'कोर्स';
        }
    }
  }

  String _freeLabel(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'मोफत';
      case 'en':
        return 'FREE';
      default:
        return 'मुफ्त';
    }
  }

  String _paidLabel(BuildContext context) {
    switch (_language(context)) {
      case 'mr':
        return 'पेड';
      case 'en':
        return 'PAID';
      default:
        return 'पेड';
    }
  }

  void _openContent(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningContentDetailScreen(
          data: data,
          title: _getContentTitle(context, data),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _title(context),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xff111827),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _collection.where('published', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load learning content.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff1565FF), Color(0xff0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _title(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _subtitle(context),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (docs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  sliver: SliverList.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final data = {
                        ...docs[index].data(),
                        'id': docs[index].id,
                      };

                      return _LearningCard(
                        title: _getContentTitle(context, data),
                        description: _getContentDescription(context, data),
                        type: _typeLabel(
                          context,
                          data['type']?.toString() ?? 'course',
                        ),
                        access: data['access']?.toString() ?? 'free',
                        price: data['price'],
                        imageUrl:
                            data['coverImageUrl']?.toString().trim() ?? '',
                        freeLabel: _freeLabel(context),
                        paidLabel: _paidLabel(context),
                        onTap: () => _openContent(context, data),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final String access;
  final dynamic price;
  final String imageUrl;
  final String freeLabel;
  final String paidLabel;
  final VoidCallback onTap;

  const _LearningCard({
    required this.title,
    required this.description,
    required this.type,
    required this.access,
    required this.price,
    required this.imageUrl,
    required this.freeLabel,
    required this.paidLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = access == 'paid';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            else
              _placeholder(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEAF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            color: Color(0xff1565FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xfffff3e8)
                              : const Color(0xffEAF9F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPaid
                              ? price != null
                                    ? '$paidLabel • ₹$price'
                                    : paidLabel
                              : freeLabel,
                          style: TextStyle(
                            color: isPaid
                                ? const Color(0xffC2410C)
                                : const Color(0xff16803A),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff111827),
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xff667085),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        isPaid ? 'View Details' : 'Open',
                        style: const TextStyle(
                          color: Color(0xff1565FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xff1565FF),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xffEAF2FF),
      child: const Icon(
        Icons.school_rounded,
        size: 55,
        color: Color(0xff1565FF),
      ),
    );
  }
}

class LearningContentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String title;

  const LearningContentDetailScreen({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  State<LearningContentDetailScreen> createState() =>
      _LearningContentDetailScreenState();
}

class _LearningContentDetailScreenState
    extends State<LearningContentDetailScreen> {
  String _language(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  String _content(BuildContext context) {
    final language = _language(context);

    final keys = switch (language) {
      'mr' => ['contentMr', 'contentHi', 'contentEn'],
      'en' => ['contentEn', 'contentHi', 'contentMr'],
      _ => ['contentHi', 'contentMr', 'contentEn'],
    };

    for (final key in keys) {
      final value = widget.data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  Future<void> _startPayment() async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PremiumPurchaseScreen(initialPlan: 'monthly'),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<bool> _hasPremiumAccess() async {
    try {
      final status = await const PremiumRepositoryImpl().getPremiumStatus();
      return status == PremiumStatus.premium;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = widget.data['access']?.toString() ?? 'free';
    final isPaid = access == 'paid';

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<bool>(
        future: isPaid ? _hasPremiumAccess() : Future.value(true),
        builder: (context, snapshot) {
          final premiumUnlocked = snapshot.data == true;
          final canRead = !isPaid || premiumUnlocked;

          if (isPaid && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.data['coverImageUrl']?.toString().isNotEmpty == true)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.data['coverImageUrl'].toString(),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 18),

                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff111827),
                  ),
                ),

                const SizedBox(height: 12),

                if (canRead)
                  Text(
                    _content(context),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xff344054),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF4FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'This learning content is available with FraudRoko Premium.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                if (isPaid && !premiumUnlocked)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _startPayment,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Get Premium with Google Play'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final url = widget.data['url']?.toString().trim() ?? '';

                        if (url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Content link is not available.'),
                            ),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Content link is ready.')),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Open Content'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
