// lib/service/view/my_investments/my_investment_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_investment_details.dart';

class MyInvestmentScreen extends StatefulWidget {
  const MyInvestmentScreen({super.key, this.items});

  /// Optional: inject your own items. If null, demo data is shown.
  final List<InvestmentItem>? items;

  @override
  State<MyInvestmentScreen> createState() => _MyInvestmentScreenState();
}

class _MyInvestmentScreenState extends State<MyInvestmentScreen> {
  late List<InvestmentItem> _items;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items ?? _sampleItems();
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    // simple visual shuffle to simulate refresh
    _items = List.of(_items)..shuffle();
    setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Builder(
            builder: (_) {
              if (_refreshing && _items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_items.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Text(
                        'No investments yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final it = _items[i];

                  final status = it.status ?? 'In Progress';
                  final statusColor = status.toLowerCase().contains('complete')
                      ? const Color(0xFF58D38C)
                      : const Color(0xFFFF8A34);

                  final progress =
                  ((it.progressPct ?? 0) / 100).clamp(0, 1).toDouble();
                  final goalText = it.fundingGoal != null
                      ? '\$${_comma(it.fundingGoal!)}'
                      : '\$—';
                  final daysLeftText = it.daysLeft != null
                      ? '${it.daysLeft} days left'
                      : '—';

                  return _InvestmentCard(
                    status: status,
                    statusColor: statusColor,
                    networkImageUrl: it.imageUrl,
                    fallbackAsset: it.imageAsset ?? 'assets/images/agriculture.jpg',
                    category: it.category ?? '',
                    title: it.name ?? '—',
                    description: it.description ?? '—',
                    progress: progress,
                    goalText: goalText,
                    daysLeftText: daysLeftText,
                    showCompleted: status.toLowerCase().contains('complete'),
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete investment?'),
                          content: const Text(
                              'This action cannot be undone.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      ) ??
                          false;
                      if (!ok) return;

                      setState(() {
                        _items.removeAt(i);
                      });
                      Get.snackbar('Deleted', 'Investment removed',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    onView: () {
                      Get.to(
                            () => MyInvestmentDetailScreen(
                          investmentId: it.id,
                          detail: it.toDetail(),
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------- Local-only UI Card (no Provider/API) ----------
class _InvestmentCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String? networkImageUrl; // may be null
  final String fallbackAsset;
  final String category;
  final String title;
  final String description;
  final double progress; // 0..1
  final String goalText;
  final String daysLeftText;
  final bool showCompleted;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _InvestmentCard({
    required this.status,
    required this.statusColor,
    required this.networkImageUrl,
    required this.fallbackAsset,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    required this.goalText,
    required this.daysLeftText,
    required this.showCompleted,
    required this.onDelete,
    required this.onView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF15181C);
    const accent = Color(0xFFFF8A34);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242931)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          // Image + status badge
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: networkImageUrl == null
                      ? Image.asset(
                    fallbackAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _brokenImage(),
                  )
                      : Image.network(
                    networkImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, w, ev) =>
                    ev == null ? w : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => _brokenImage(),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.7)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),

                // exactly 3 lines
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12.5,
                      height: 1.35),
                ),

                const SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressBar(
                      value: progress,
                      background: const Color(0xFF1E232A),
                      fill: const Color(0xFFFF8A00),
                      height: 10,
                      radius: 6,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).round()}% of $goalText',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          daysLeftText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                          side: MaterialStateProperty.resolveWith<BorderSide>(
                                  (states) {
                                final disabled =
                                states.contains(MaterialState.disabled);
                                return BorderSide(
                                    color: const Color(0xFFFF6A00)
                                        .withOpacity(disabled ? 0.45 : 1),
                                    width: 1.5);
                              }),
                          foregroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                final disabled =
                                states.contains(MaterialState.disabled);
                                return const Color(0xFFFF6A00)
                                    .withOpacity(disabled ? 0.45 : 1);
                              }),
                          overlayColor: MaterialStateProperty.all(
                              const Color(0xFFFF6A00).withOpacity(0.08)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 12)),
                        ),
                        onPressed: showCompleted ? null : onDelete,
                        child: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: onView,
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brokenImage() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child:
    const Icon(Icons.broken_image_outlined, color: Colors.white70),
  );
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color background;
  final Color fill;
  final double height;
  final double radius;

  const _ProgressBar({
    required this.value,
    required this.background,
    required this.fill,
    this.height = 10,
    this.radius = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: background,
        valueColor: AlwaysStoppedAnimation<Color>(fill),
      ),
    );
  }
}

// ---------- Local model & helpers (no Provider) ----------
class InvestmentItem {
  final String id;
  final String? name;
  final String? description;
  final int? fundingGoal; // USD
  final int? progressPct; // 0..100
  final int? daysLeft;
  final String? category;
  final String? status;
  final String? imageUrl; // network
  final String? imageAsset; // local asset
  final String? location;

  const InvestmentItem({
    required this.id,
    this.name,
    this.description,
    this.fundingGoal,
    this.progressPct,
    this.daysLeft,
    this.category,
    this.status,
    this.imageUrl,
    this.imageAsset,
    this.location,
  });

  InvestmentDetail toDetail() => InvestmentDetail(
    name: name,
    category: category,
    location: location,
    description: description,
    terms:
    'Min ticket: \$100\nTarget ROI: 8–12%\nLock-up: 12 months\nDividends paid quarterly',
    fundingGoal: fundingGoal,
    progressPct: progressPct,
    daysLeft: daysLeft,
    imageUrl: imageUrl,
    imageAsset: imageAsset,
    gallery: const [],
  );
}

List<InvestmentItem> _sampleItems() => const [
  InvestmentItem(
    id: 'inv_001',
    name: 'Green Solar Fields',
    description:
    'Community-backed solar installation powering 120 homes.',
    fundingGoal: 50000,
    progressPct: 42,
    daysLeft: 12,
    category: 'Energy',
    status: 'In Progress',
    imageAsset: 'assets/images/agriculture.jpg',
    location: 'Austin, TX',
  ),
  InvestmentItem(
    id: 'inv_002',
    name: 'Waste-to-Biogas Plant',
    description:
    'Turning organic waste into clean biogas for local industry.',
    fundingGoal: 120000,
    progressPct: 75,
    daysLeft: 6,
    category: 'Sustainability',
    status: 'In Progress',
    imageUrl:
    'https://images.unsplash.com/photo-1570378164207-c63f91e0b5b5?q=80&w=1200&auto=format&fit=crop',
    location: 'Sacramento, CA',
  ),
  InvestmentItem(
    id: 'inv_003',
    name: 'Urban Hydroponics Pods',
    description:
    'Modular indoor farms placed in underused retail spaces.',
    fundingGoal: 80000,
    progressPct: 100,
    daysLeft: 0,
    category: 'Agriculture',
    status: 'Completed',
    imageAsset: 'assets/images/wind-mill.jpg',
    location: 'Seattle, WA',
  ),
];

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
