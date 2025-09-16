// lib/investment_detail_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../invest.dart';

class InvestmentDetailScreen extends StatelessWidget {
  const InvestmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F0F12);
    const card = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent = Color(0xFFFF7A1A);

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
              // ---------- HERO ----------
              _HeroImage(
                image:
                'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1400&auto=format&fit=crop',
              ),
              const SizedBox(height: 10),

              // ---------- CONTENT CARD ----------
              Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agriculture',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.65),
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('Urban Farming Initiative',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc tincidunt metus ex egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                      style: TextStyle(
                          height: 1.35,
                          color: Colors.white.withOpacity(.75),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 10),

                    // location pill
                    _Pill(
                      icon: CupertinoIcons.location_solid,
                      label: 'New York, NY',
                    ),
                    const SizedBox(height: 12),

                    // progress block
                    Container(
                      decoration: BoxDecoration(
                        color: inner,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _ProgressBar(value: 0.45, color: accent),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Metric(
                                top: '45%',
                                bottom: 'of \$25,000',
                              ),
                              _DotDivider(),
                              const _Metric(
                                top: '28',
                                bottom: 'Backers',
                              ),
                              _DotDivider(),
                              const _Metric(
                                top: '10',
                                bottom: 'Days left',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // invest button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Get.to(InvestScreen());
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
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------- ABOUT ----------
              _SectionCard(
                title: 'About This Project',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _para(),
                    const SizedBox(height: 10),
                    _para(),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------- GALLERY ----------
              _SectionCard(
                title: 'Gallery',
                child: Row(
                  children: const [
                    Expanded(
                      child: _GalleryThumb(
                        image:
                        'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _GalleryThumb(
                        image:
                        'https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=1200&auto=format&fit=crop',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------- TERMS ----------
              _SectionCard(
                title: 'Investment Terms',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Bullet(text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
                    _Bullet(text: 'Quisque tempus tortor nec pharetra viverra.'),
                    _Bullet(text: 'Fusce id metus et amet leo convallis convallis.'),
                    _Bullet(text: 'Duis mollis dolor sit amet tortor egestas, vel consectetur dui finibus.'),
                    _Bullet(text: 'Duis lacus quam vel est sodales, sit amet tristique mauris fringilla.'),
                    _Bullet(text: 'Sed in leo velit ultricies dignissim.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // sample paragraph
  static Widget _para() => Text(
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis. Curabitur sed nunc vitae ex tincidunt porttitor blandit eget purus. Integer ut malesuada fames ac ante ipsum primis in faucibus. In a neque at neque convallis mollis eget sed velit. Fusce semper convallis dapibus.',
    style: TextStyle(
      height: 1.45,
      fontSize: 13,
      color: Colors.white.withOpacity(.78),
    ),
  );
}

/// ---------- HERO IMAGE WITH OVERLAYS ----------
class _HeroImage extends StatelessWidget {
  final String image;
  const _HeroImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Ink.image(image: NetworkImage(image), fit: BoxFit.cover),
          ),
          // top controls
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Row(
              children: [
                _roundBtn(const Icon(CupertinoIcons.back)),
                const Spacer(),
                _roundBtn(const Icon(CupertinoIcons.share)),
                const SizedBox(width: 8),
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
                color: Colors.black.withOpacity(.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage:
                    NetworkImage('https://i.pravatar.cc/100?img=24'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Eleanor_Pen',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12)),
                      Text('@eleanorp',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(.75))),
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
          // gradient bottom fade (for readability)
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

  static Widget _roundBtn(Widget icon) => Container(
    height: 36,
    width: 36,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.45),
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: icon,
  );
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

/// ---------- REUSABLE PIECES ----------
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
  final String image;
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
