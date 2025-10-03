// lib/investment_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';


import '../../create_service/provider/investment_provider.dart';
import '../invest.dart';
import 'investment_screen.dart';

class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;
  const InvestmentDetailScreen({super.key, required this.investmentId});

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // fetch details once the screen mounts
    Future.microtask(() =>
        context.read<InvestmentProvider>().fetchInvestmentById(widget.investmentId));
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F0F12);
    const card = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent = Color(0xFFFF7A1A);

    final p = context.watch<InvestmentProvider>();

    // simple loading / error gates (UI design untouched)
    if (p.loadingOne) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bg),
        home: const Scaffold(
          body: SafeArea(child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (p.currentInvestment == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bg),
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Text(
                (p.error?.isNotEmpty ?? false) ? p.error! : 'Investment not found',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }

    final inv = p.currentInvestment!;

    // pull dynamic values (safe — won’t crash if a getter is missing)
    final title = _name(inv);
    final category = _category(inv);
    final desc = _description(inv);
    final loc = _location(inv);
    final imagePathOrUrl = _imageUrl(inv);

    final goal = _goal(inv);
    final progressPct = _progressPct(inv);
    final daysLeft = _daysLeft(inv);
    final backers = _backers(inv) ?? 0;

    // GALLERY (use up to two images when available, else keep your originals)
    final gallery = _galleryImages(inv);
    final g1 = gallery.isNotEmpty
        ? gallery[0]
        : 'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop';
    final g2 = gallery.length > 1
        ? gallery[1]
        : 'https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=1200&auto=format&fit=crop';

    // TERMS (if your API returns a single string, we split to keep your bullet design)
    final termsText = _terms(inv);
    final bullets = termsText.isNotEmpty
        ? termsText.split(RegExp(r'\r?\n')).where((s) => s.trim().isNotEmpty).toList()
        : const [
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'Quisque tempus tortor nec pharetra viverra.',
      'Fusce id metus et amet leo convallis convallis.',
      'Duis mollis dolor sit amet tortor egestas, vel consectetur dui finibus.',
      'Duis lacus quam vel est sodales, sit amet tristique mauris fringilla.',
      'Sed in leo velit ultricies dignissim.',
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: card,
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // ---------- HERO (kept) ----------
              _HeroImage(image: imagePathOrUrl),
              const SizedBox(height: 10),

              // ---------- CONTENT CARD (kept) ----------
              Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc.isNotEmpty
                          ? desc
                          : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc tincidunt metus ex egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                      style: TextStyle(
                        height: 1.35,
                        color: Colors.white.withOpacity(.75),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // location pill (kept)
                    if (loc.isNotEmpty) ...[
                      _Pill(icon: CupertinoIcons.location_solid, label: loc),
                      const SizedBox(height: 12),
                    ],

                    // progress block (kept)
                    Container(
                      decoration: BoxDecoration(
                        color: inner,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _ProgressBar(
                            value: (progressPct / 100).clamp(0, 1),
                            color: accent,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Metric(
                                top: '$progressPct%',
                                bottom: 'of \$${_fmt(goal)}',
                              ),
                              _DotDivider(),
                              _Metric(
                                top: '$backers',
                                bottom: 'Backers',
                              ),
                              _DotDivider(),
                              _Metric(
                                top: '$daysLeft',
                                bottom: 'Days left',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // invest button (kept)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Get.to(
                                () => InvestScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Invest Now',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------- ABOUT (kept) ----------
              _SectionCard(
                title: 'About This Project',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc.isNotEmpty
                          ? desc
                          : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis.',
                      style: TextStyle(
                        height: 1.45,
                        fontSize: 13,
                        color: Colors.white.withOpacity(.78),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      desc.isNotEmpty
                          ? desc
                          : 'Curabitur sed nunc vitae ex tincidunt porttitor blandit eget purus.',
                      style: TextStyle(
                        height: 1.45,
                        fontSize: 13,
                        color: Colors.white.withOpacity(.78),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------- GALLERY (kept) ----------
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

              const SizedBox(height: 12),

              // ---------- TERMS (kept layout) ----------
              _SectionCard(
                title: 'Investment Terms',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final b in bullets) _Bullet(text: b),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // Safe access helpers (NO design changes)
  // -----------------------------
  String _name(dynamic inv) {
    try { final v = (inv as dynamic).name; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    try { final v = (inv as dynamic).title; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    return 'Urban Farming Initiative';
  }

  String _description(dynamic inv) {
    try { final v = (inv as dynamic).description; if (v is String) return v; } catch (_) {}
    return '';
  }

  String _category(dynamic inv) {
    try {
      final v = (inv as dynamic).category;
      if (v is String) return v;
      if (v is List) return v.join(', ');
    } catch (_) {}
    return 'Agriculture';
  }

  String _location(dynamic inv) {
    try { final v = (inv as dynamic).location; if (v is String) return v; } catch (_) {}
    return '';
  }

  String _terms(dynamic inv) {
    try { final v = (inv as dynamic).investment_terms; if (v is String) return v; } catch (_) {}
    try { final v = (inv as dynamic).terms; if (v is String) return v; } catch (_) {}
    return '';
  }

  String _imageUrl(dynamic inv) {
    // Direct URL fields
    try { final v = (inv as dynamic).imageUrl; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    try { final v = (inv as dynamic).imageLink; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    // Array forms: image / images
    try {
      final arr = (inv as dynamic).image;
      if (arr is List && arr.isNotEmpty) {
        final f = arr.first;
        if (f is Map && f['url'] is String) return f['url'] as String;
        if (f is String) return f;
      }
    } catch (_) {}
    try {
      final arr = (inv as dynamic).images;
      if (arr is List && arr.isNotEmpty) {
        final f = arr.first;
        if (f is Map && f['url'] is String) return f['url'] as String;
        if (f is String) return f;
      }
    } catch (_) {}
    // Fallback to your original asset (design unchanged)
    return 'assets/images/agriculture.jpg';
  }

  List<String> _galleryImages(dynamic inv) {
    final out = <String>[];
    try {
      final arr = (inv as dynamic).images;
      if (arr is List) {
        for (final x in arr) {
          if (x is String) out.add(x);
          if (x is Map && x['url'] is String) out.add(x['url'] as String);
        }
      }
    } catch (_) {}
    try {
      final arr = (inv as dynamic).image;
      if (arr is List) {
        for (final x in arr) {
          if (x is String) out.add(x);
          if (x is Map && x['url'] is String) out.add(x['url'] as String);
        }
      }
    } catch (_) {}
    return out.take(2).toList();
  }

  int _goal(dynamic inv) {
    try { final v = (inv as dynamic).fundingGoal; if (v is num) return v.toInt(); } catch (_) {}
    try { final v = (inv as dynamic).funding_goal; if (v is num) return v.toInt(); } catch (_) {}
    return 25000; // keep your original visual if missing
  }

  num _raised(dynamic inv) {
    try { final v = (inv as dynamic).amountRaised; if (v is num) return v; } catch (_) {}
    try { final v = (inv as dynamic).raised; if (v is num) return v; } catch (_) {}
    return 0;
  }

  String? _createdAtIso(dynamic inv) {
    try { final v = (inv as dynamic).createdAt; if (v is String) return v; } catch (_) {}
    try { final v = (inv as dynamic).created_at; if (v is String) return v; } catch (_) {}
    return null;
  }

  dynamic _fundingDuration(dynamic inv) {
    try { return (inv as dynamic).fundingDuration; } catch (_) {}
    try { return (inv as dynamic).funding_duration; } catch (_) {}
    return null;
  }

  int _daysLeft(dynamic inv) {
    final fd = _fundingDuration(inv);
    final createdAtIso = _createdAtIso(inv);

    int totalDays = 0;
    if (fd is int) {
      totalDays = fd;
    } else if (fd is String) {
      final s = fd.toLowerCase();
      final n = int.tryParse(RegExp(r'\d+').firstMatch(s)?.group(0) ?? '');
      if (n != null) {
        if (s.contains('month')) totalDays = n * 30;
        else if (s.contains('week')) totalDays = n * 7;
        else if (s.contains('day')) totalDays = n;
      }
    }
    if (totalDays == 0) return 10; // keep your original visual if missing

    DateTime start;
    try {
      start = createdAtIso != null ? DateTime.parse(createdAtIso) : DateTime.now();
    } catch (_) {
      start = DateTime.now();
    }
    final end = start.add(Duration(days: totalDays));
    final left = end.difference(DateTime.now()).inDays;
    return left < 0 ? 0 : left;
  }

  int _progressPct(dynamic inv) {
    // explicit field if present
    try { final v = (inv as dynamic).progressPct; if (v is num) return v.clamp(0, 100).toInt(); } catch (_) {}
    try { final v = (inv as dynamic).progress;    if (v is num) return v.clamp(0, 100).toInt(); } catch (_) {}

    // compute from raised/goal
    final g = _goal(inv);
    final r = _raised(inv);
    if (g > 0) return ((r / g) * 100).clamp(0, 100).toInt();

    // keep your original look if we can’t compute
    return 45;
  }

  int? _backers(dynamic inv) {
    try { final v = (inv as dynamic).backers; if (v is num) return v.toInt(); } catch (_) {}
    try { final v = (inv as dynamic).investorsCount; if (v is num) return v.toInt(); } catch (_) {}
    try { final v = (inv as dynamic).contributors; if (v is num) return v.toInt(); } catch (_) {}
    return null;
  }
}

/// ---------- HERO IMAGE WITH OVERLAYS (design kept) ----------
class _HeroImage extends StatelessWidget {
  final String image; // may be asset path or http url
  const _HeroImage({required this.image});

  bool get _isNetwork {
    final uri = Uri.tryParse(image);
    return uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: InkWell(
              onTap: () => Get.back(),
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
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
            ),
          ),

          // top controls (kept)
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Row(
              children: [
                _roundBtn(const Icon(CupertinoIcons.back),
                    onPressed: () => Get.back()),
                const Spacer(),
                _roundBtn(const Icon(CupertinoIcons.heart)),
              ],
            ),
          ),

          // author chip (kept, placeholder)
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=24'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Eleanor_Pen',
                          style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      Text('@eleanorp',
                          style: TextStyle(
                              fontSize: 10, color: Colors.white.withOpacity(.75))),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const _TinyPill(icon: CupertinoIcons.eye, label: '2.1k'),
                  const SizedBox(width: 6),
                  const _TinyPill(icon: CupertinoIcons.hand_thumbsup, label: '142'),
                ],
              ),
            ),
          ),

          // gradient bottom fade (kept)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(.45),
                      Colors.transparent,
                    ],
                  ),
                ),
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
            spreadRadius: 0,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

/// ---------- REUSABLE PIECES (unchanged) ----------
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(.9)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
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
          Text(top,
              style:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text(bottom,
              style:
              TextStyle(fontSize: 11, color: Colors.white.withOpacity(.7))),
        ],
      ),
    );
  }
}

class _DotDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 28,
      child: Center(
        child: Container(
          width: 1,
          height: 18,
          color: Colors.white.withOpacity(.12),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(.12);
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(
          children: [
            Container(color: bg),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
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
    const card = Color(0xFF1B1E23);
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
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
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Ink.image(
          image: NetworkImage(image),
          fit: BoxFit.cover,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                height: 1.4,
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

// small util (kept)
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
