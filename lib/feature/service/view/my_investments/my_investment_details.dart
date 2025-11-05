// lib/service/view/my_investments/my_investment_details.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app_ground.dart';
import '../../../models/investment.dart';


/// Local-only detail screen (can use real [Investment] or local [InvestmentDetail] fallback)
class MyInvestmentDetailScreen extends StatelessWidget {
  const MyInvestmentDetailScreen({
    super.key,
    required this.investmentId,
    this.detail,          // optional local fallback content
    this.investment,      // pass a real Investment to show live data
  });

  final String investmentId;
  final InvestmentDetail? detail;
  final Investment? investment;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0F12);
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);

    // -------- Local fallback (unchanged) --------
    final it = detail ??
        InvestmentDetail(
          name: 'Urban Farming Initiative #$investmentId',
          category: 'Agriculture',
          location: 'San Francisco, CA',
          description:
          'A pilot to retrofit unused rooftops into hydroponic farms, supplying local groceries.',
          terms: 'Min ticket: \$100\nTarget ROI: 8–12%\nLock-up: 12 months',
          fundingGoal: 25000,
          progressPct: 45,
          daysLeft: 10,
          imageAsset: 'assets/images/wind-mill.jpg',
          gallery: const [
            'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop',
            'https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=1200&auto=format&fit=crop',
          ],
        );


    // --- Author / counters from API (createdBy + counts) ---
    final authorName     = (investment?.ownerName ?? 'Eleanor Pena').trim();
    final authorUsername = (investment?.ownerUsername ?? 'eleanorp').trim(); // no '@'
    final authorAvatar   = investment?.ownerAvatarUrl
        ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2';

    final likeCount   = investment?.likeCount ?? 0;
    final likesText   = _abbr(likeCount);




    // -------- Content (prefer Investment, fallback to local) --------
    final title = (investment?.name ?? it.name ?? '—').trim();

    final category = ((investment?.category.join(', ') ?? it.category ?? '').trim().isEmpty)
        ? '—'
        : (investment?.category.join(', ') ?? it.category!);

    final location =
    ((investment?.location ?? it.location ?? '').trim().isEmpty)
        ? '—'
        : (investment?.location ?? it.location!);

    final description =
    ((investment?.description ?? it.description ?? '').trim().isEmpty)
        ? '—'
        : (investment?.description ?? it.description!);

    final goal = investment?.fundingGoal ?? it.fundingGoal;
    final goalText = goal != null ? '\$${_comma(goal)}' : '—';

    final progressPct = investment?.progressPct ?? it.progressPct ?? 0;
    final progress = (progressPct.toDouble() / 100).clamp(0, 1).toDouble();

    final dleft = investment?.daysLeft ?? it.daysLeft;
    final daysLeftText = dleft != null ? '$dleft days left' : '—';

    // hero + gallery
    final heroImageUrl = investment?.primaryImageUrl ?? it.imageUrl;
    final heroImageAsset = it.imageAsset; // keep local asset fallback
    final gallery = (investment?.images
        .map((e) => e.url)
        .where((u) => u.isNotEmpty)
        .toList() ??
        []) +
        it.gallery;

    final g1 = gallery.isNotEmpty
        ? gallery[0]
        : 'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop';
    final g2 = gallery.length > 1
        ? gallery[1]
        : 'https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=1200&auto=format&fit=crop';

    final termsBullets = _splitBullets(investment?.investmentTerms ?? it.terms);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.offAll(() => const AppGround());
              }
            },
          ),
          title: const Text('Investment Details',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          centerTitle: false,
        ),
        backgroundColor: bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              // main card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Hero =====
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: heroImageAsset != null
                                ? Image.asset(
                              heroImageAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _brokenImage(),
                            )
                                : (heroImageUrl != null
                                ? Image.network(
                              heroImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (c, w, ev) =>
                              ev == null ? w : const Center(child: CircularProgressIndicator()),
                              errorBuilder: (_, __, ___) => _brokenImage(),
                            )
                                : _brokenImage()),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Row(children: const [Spacer()]),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 10,
                          child: _AuthorChip(
                            name: authorName,
                            username: authorUsername,
                            avatarUrl: authorAvatar,
                            viewsText: '21k', // investors count (e.g. 21k)
                            likesText: likesText, // likeCount   (e.g. 142)
                          ),
                        ),

                      ],
                    ),

                    // ===== Body =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Badge(text: category, color: accent),
                          const SizedBox(height: 8),
                          Text(title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          _Para(description),
                          const SizedBox(height: 12),
                          _InfoBar(icon: Icons.location_on_outlined, label: location),
                          const SizedBox(height: 16),
                          _ProgressBar(value: progress, background: const Color(0xFF1E232A), fill: accent),
                          const SizedBox(height: 8),
                          _MetricsRow(
                            percentText: '${(progress * 100).round()}%',
                            goalText: goalText,
                            daysLeftText: daysLeftText,
                          ),
                          const SizedBox(height: 18),

                          // About
                          const _SectionTitle('About This Project'),
                          const SizedBox(height: 8),
                          _Para(description),
                          const SizedBox(height: 10),
                          _Para(description),
                          const SizedBox(height: 16),

                          // Gallery
                          const _SectionTitle('Gallery'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _RoundedImage(g1)),
                              const SizedBox(width: 10),
                              Expanded(child: _RoundedImage(g2)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Terms
                          const _SectionTitle('Investment Terms'),
                          const SizedBox(height: 6),
                          for (final b in termsBullets) _Bullet(b),

                          const SizedBox(height: 16),

                          // Investors (static demo)
                          const _SectionTitle('Investor'),
                          const SizedBox(height: 8),
                          const InvestorTile(
                            name: 'Eleanor Pena',
                            subtitle: '3 Investments',
                            amount: '\$1,000',
                            avatar: 'https://picsum.photos/200',
                          ),
                          const SizedBox(height: 10),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brokenImage() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined, color: Colors.white70),
  );
}

// ===== atoms & molecules =====

class _AuthorChip extends StatelessWidget {
  final String name;
  final String username;  // without '@'
  final String avatarUrl;
  final String viewsText; // left pill: investors count
  final String likesText; // right pill: like count

  const _AuthorChip({
    super.key,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.viewsText,
    required this.likesText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '@$username',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        _TinyPill(text: viewsText),
        const SizedBox(width: 6),
        _TinyPill(text: likesText),
      ],
    );
  }
}


// class _AuthorChip extends StatelessWidget {
//   final String name;
//   final String username;  // without '@'
//   final String avatarUrl;
//   final String viewsText; // e.g. "21k"
//   final String likesText; // e.g. "142"
//
//   const _AuthorChip({
//     super.key,
//     required this.name,
//     required this.username,
//     required this.avatarUrl,
//     required this.viewsText,
//     required this.likesText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl)),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(name,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.95),
//                   fontWeight: FontWeight.w600,
//                 )),
//             Text('@$username',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.7),
//                   fontSize: 12,
//                 )),
//           ],
//         ),
//         const SizedBox(width: 8),
//         _TinyPill(text: viewsText),
//         const SizedBox(width: 6),
//         _TinyPill(text: likesText),
//       ],
//     );
//   }
// }

class _TinyPill extends StatelessWidget {
  final String text;
  const _TinyPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBar({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A313A)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color background;
  final Color fill;
  const _ProgressBar({required this.value, required this.background, required this.fill});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final filled = (width * value).clamp(0.0, width);
        return Container(
          height: 8,
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: filled,
              decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      },
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final String percentText; // e.g. "45%"
  final String goalText; // e.g. "$25,000"
  final String daysLeftText; // e.g. "10 days left"
  const _MetricsRow({required this.percentText, required this.goalText, required this.daysLeftText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Metric(top: percentText, bottom: 'of $goalText'),
        const _Metric(top: '—', bottom: 'Backers'),
        _Metric(
          top: daysLeftText == '—' ? '—' : daysLeftText.split(' ').first,
          bottom: 'Days left',
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String top;
  final String bottom;
  const _Metric({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(top, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(bottom, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16));
  }
}

class _Para extends StatelessWidget {
  final String text;
  const _Para(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Colors.white.withOpacity(0.78), height: 1.45));
  }
}

class _RoundedImage extends StatelessWidget {
  final String url;
  const _RoundedImage(this.url);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}

class InvestorTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String amount;
  final String avatar;

  const InvestorTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF1A1F26);
    const border = Color(0xFF2A313A);
    const accent = Color(0xFFFF6A00);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Investment Amount:',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(amount,
                  style: const TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration:
            BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.78), height: 1.45)),
          ),
        ],
      ),
    );
  }
}

/// Lightweight local model (no Provider/API) used only for demo fallback.
class InvestmentDetail {
  final String? name;
  final String? category;
  final String? location;
  final String? description;
  final String? terms; // newline-separated bullets
  final int? fundingGoal; // USD
  final int? progressPct; // 0..100
  final int? daysLeft;
  final String? imageUrl; // network
  final String? imageAsset; // local asset
  final List<String> gallery;

  const InvestmentDetail({
    this.name,
    this.category,
    this.location,
    this.description,
    this.terms,
    this.fundingGoal,
    this.progressPct,
    this.daysLeft,
    this.imageUrl,
    this.imageAsset,
    this.gallery = const [],
  });
}

// ===== helpers =====
String _comma(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[i]);
    final left = s.length - i - 1;
    if (left % 3 == 0 && left != 0) b.write(',');
  }
  return b.toString();
}

List<String> _splitBullets(String? s) {
  final t = (s ?? '').trim();
  if (t.isEmpty) {
    return const [
      'Min ticket: \$100',
      'Target ROI: 8–12%',
      'Lock-up: 12 months',
      'Dividends paid quarterly',
    ];
  }
  return t.split(RegExp(r'\r?\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

String _abbr(int? n) {
  final v = n ?? 0;
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
  return v.toString();
}
