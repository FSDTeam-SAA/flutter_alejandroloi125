// lib/feature/investment/view/investment_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:alejandroloi/providers/investment_provider.dart';
import '../../models/investment.dart';
import '../invest.dart';

// ===== Theme (match the mock) =====
const _bg = Color(0xFF0F0F12);
const _card = Color(0xFF1B1E23);
const _inner = Color(0xFF23262B);
const _accent = Color(0xFFFF7A1A);

BoxDecoration _cardBox({Color color = _card, double radius = 12}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(.06), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.13),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );

class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;
  final Investment? prefetched;
  const InvestmentDetailScreen({
    super.key,
    required this.investmentId,
    this.prefetched,
  });

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  Investment? _inv;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.prefetched != null) {
      setState(() {
        _inv = widget.prefetched;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final inv = await context.read<InvestmentProvider>().getById(
        widget.investmentId,
      );
      if (!mounted) return;
      setState(() {
        _inv = inv;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(),
                const SizedBox(height: 16),
                Container(
                  decoration: _cardBox(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Couldn’t load details',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.white.withOpacity(.75)),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
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

    final inv = _inv!;
    final title = inv.name.isNotEmpty ? inv.name : 'Urban Farming Initiative';
    final category = inv.category.isNotEmpty
        ? inv.category.join(', ')
        : 'Agriculture';
    final rawDesc = inv.description.isNotEmpty
        ? inv.description
        : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.';
    final desc = _scrubQuotes(rawDesc);
    final loc = inv.location;
    final imageUrl =
        inv.primaryImageUrl ??
        'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop';
    final goal = inv.fundingGoal ?? 25000; // mock shows $25,000
    final progress = inv.progressPct.clamp(0, 100);
    final daysLeft = _daysLeft(inv.fundingDuration) == 0
        ? 10
        : _daysLeft(inv.fundingDuration);
    final backers = 28; // static for mock

    final gallery = inv.images
        .map((e) => e.url)
        .where((u) => u.isNotEmpty)
        .toList();
    final g1 = gallery.isNotEmpty
        ? gallery[0]
        : 'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop';
    final g2 = gallery.length > 1
        ? gallery[1]
        : 'https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=1200&auto=format&fit=crop';

    final bullets = inv.investmentTerms.trim().isNotEmpty
        ? inv.investmentTerms
              .split(RegExp(r'\r?\n'))
              .where((s) => s.trim().isNotEmpty)
              .toList()
        : const [
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            'Quisque tempus tortor nec pharetra viverra.',
            'Fusce id metus at amet leo convallis convallis.',
            'Duis mollis dolor sit amet tortor egestas, vel consectetur dui finibus.',
            'Duis iaculis quam vel est sodales, sit amet tristique mauris fringilla.',
            'Sed in mi eu velit ultrices dignissim.',
          ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _TopBar(),
            const SizedBox(height: 10),

            // ===== HERO =====
            _HeroCard(image: imageUrl),
            const SizedBox(height: 14),

            // ===== CONTENT CARD =====
            Container(
              decoration: _cardBox(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category (uppercase like the mock)
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .25,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title (explicit white so it never looks dim)
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Short description (limited lines on card)
                  Text(
                    desc,
                    style: TextStyle(
                      height: 1.38,
                      color: Colors.white.withOpacity(.78),
                      fontSize: 13,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // Location pill
                  if (loc.isNotEmpty) ...[
                    _LocationPill(label: loc),
                    const SizedBox(height: 16),
                  ],

                  // Progress block
                  Container(
                    decoration: _cardBox(color: _inner, radius: 10),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                    child: Column(
                      children: [
                        _ProgressBar(value: (progress / 100), color: _accent),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Metric(
                              top: '$progress%',
                              bottom: 'of \$${_fmt(goal)}',
                            ),
                            _DividerV(),
                            _Metric(top: '$backers', bottom: 'Backers'),
                            _DividerV(),
                            _Metric(top: '$daysLeft', bottom: 'Days left'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CTA
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Get.to(
                          () => InvestScreen(
                            investmentId: widget.investmentId,
                            investmentTitle: title,
                          ),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      child: const Text('Invest Now'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== About =====
            _SectionCard(
              title: 'About This Project',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    style: TextStyle(
                      height: 1.45,
                      fontSize: 13,
                      color: Colors.white.withOpacity(.82),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Curabitur sed nunc vitae ex tincidunt porttitor blandit eget purus. Interdum et malesuada fames ac ante ipsum primis in faucibus. In a neque at neque convallis mollis eget sed velit. Fusce semper convallis dapibus. Integer sapien mi, vehicula in lorem non, blandit vestibulum augue. Aenean ac posuere quam. Nam dapibus est ut rutrum posuere.',
                    style: TextStyle(
                      height: 1.45,
                      fontSize: 13,
                      color: Colors.white.withOpacity(.82),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== Gallery =====
            _SectionCard(
              title: 'Gallery',
              child: Row(
                children: [
                  Expanded(child: _GalleryThumb(image: g1)),
                  const SizedBox(width: 10),
                  Expanded(child: _GalleryThumb(image: g2)),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== Terms =====
            _SectionCard(
              title: 'Investment Terms',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final b in bullets) _Bullet(text: b),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: .25,
                    child: Container(
                      height: 3,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Header row: back + label
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _roundBackBtn(),
        const SizedBox(width: 8),
        const Text(
          'Investments Details',
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
      ],
    );
  }

  static Widget _roundBackBtn() => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF2F6F80).withOpacity(0.35),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          offset: const Offset(0, 2),
          color: Colors.black.withOpacity(.10),
        ),
      ],
    ),
    child: IconButton(
      icon: const Icon(CupertinoIcons.back),
      color: Colors.white,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      onPressed: () => Get.back(),
    ),
  );
}

class _HeroCard extends StatelessWidget {
  final String image;
  const _HeroCard({required this.image});

  bool get _isNetwork {
    final u = Uri.tryParse(image);
    return u != null && (u.scheme == 'http' || u.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isNetwork
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _broken(),
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _broken(),
                  ),
          ),
          // gradient overlay
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(.35),
                      Colors.transparent,
                      Colors.black.withOpacity(.60),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // top controls
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Row(
              children: [
                // _roundBtn(const Icon(CupertinoIcons.back), onPressed: () => Get.back()),
                const Spacer(),
                _roundBtn(const Icon(CupertinoIcons.heart)),
              ],
            ),
          ),
          // author chip
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(
                  .55,
                ), // slightly denser for contrast
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/100?img=24',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Eleanor_Pen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '@eleanorp',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const _TinyPill(icon: CupertinoIcons.eye, label: '2.1k'),
                  const SizedBox(width: 6),
                  const _TinyPill(
                    icon: CupertinoIcons.hand_thumbsup,
                    label: '142',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _broken() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined),
  );

  Widget _roundBtn(Icon icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2F6F80).withOpacity(0.35),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      child: IconButton(
        icon: icon,
        color: Colors.white,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        onPressed: onPressed,
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TinyPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.55),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withOpacity(.12), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(.95)),
          const SizedBox(width: 5),
          const Text(
            // label dynamic below via RichText to keep style strict
            '',
            style: TextStyle(
              fontSize: 0,
            ), // placeholder (we'll render with RichText)
          ),
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: .1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String label;
  const _LocationPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _inner,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(.10), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.location_solid,
            size: 14,
            color: Colors.white.withOpacity(.95),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String top;
  final String bottom;
  const _Metric({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            top,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            bottom,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(.74),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerV extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      child: Center(
        child: Container(
          width: 1,
          height: 22,
          color: Colors.white.withOpacity(.14),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    const track = Color(0xFF3A3D43); // stronger contrast
    return SizedBox(
      height: 8, // a bit thicker like the mock
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, // crisp, not dim
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: .1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  final String image; // url
  const _GalleryThumb({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(.18), width: 1),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            image,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            loadingBuilder: (ctx, child, evt) {
              if (evt == null) return child;
              return Container(
                color: _inner,
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(),
              );
            },
            errorBuilder: (ctx, err, stack) => Container(
              color: _inner,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white.withOpacity(.7),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                height: 1.45,
                fontSize: 13,
                color: Colors.white.withOpacity(.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== helpers =====
String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) buf.write(',');
  }
  return buf.toString();
}

int _daysLeft(String? fundingDuration) {
  final s = (fundingDuration ?? '').toLowerCase().trim();
  if (s.isEmpty) return 10; // default like mock
  final m = RegExp(r'\d+').firstMatch(s)?.group(0);
  final n = int.tryParse(m ?? '');
  if (n == null) return 10;
  if (s.contains('month')) return n * 30;
  if (s.contains('week')) return n * 7;
  if (s.contains('day')) return n;
  return n;
}

// Removes leading/trailing quotes or smart quotes so text never shows stray “ or ”
String _scrubQuotes(String s) =>
    s.trim().replaceAll(RegExp(r'''^[“"'`‘’]+|[”"'`‘’]+$'''), '');
