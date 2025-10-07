// lib/feature/investment/view/investments_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_ground.dart';
import 'investment_detail.dart'; // <- Make sure this screen accepts `investment:` now

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({
    super.key,
    this.investments = const <dynamic>[],
    this.loading = false,
    this.error,
  });

  /// Prefetched investments (no provider/API here).
  final List<dynamic> investments;

  /// Optional UI flags (if you want to show a loader or an error).
  final bool loading;
  final String? error;

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  final _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F0F12);
    const card = Color(0xFF1B1E23);
    const accent = Color(0xFFFF7A1A);

    final query = _searchCtl.text.trim().toLowerCase();
    final items = widget.investments;

    final filtered = items.where((inv) {
      final name = _name(inv).toLowerCase();
      final loc = _location(inv).toLowerCase();
      final cat = _category(inv).toLowerCase();
      if (query.isEmpty) return true;
      return name.contains(query) || loc.contains(query) || cat.contains(query);
    }).toList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Investments',
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
          child: RefreshIndicator(
            // Local no-op refresh to keep the UX (no API calls).
            onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 350)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // Top bar
                Row(
                  children: [
                    _IconBtn(
                      onTap: () => Get.offAll(
                            () => const AppGround(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                      child: const Icon(CupertinoIcons.back, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Investments',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),

                // Search
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.search,
                                color: Colors.white.withOpacity(.7), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search name or location',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(.6),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtl.clear();
                                  setState(() {});
                                },
                                child: Icon(CupertinoIcons.clear_thick_circled,
                                    size: 18, color: Colors.white.withOpacity(.6)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _IconBtn(
                      onTap: () {}, // (future local filters, no API)
                      child: const Icon(CupertinoIcons.slider_horizontal_3, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Content states (purely local)
                if (widget.loading) ...[
                  const _ShimmerCard(),
                  const SizedBox(height: 14),
                  const _ShimmerCard(),
                  const SizedBox(height: 14),
                  const _ShimmerCard(),
                ] else if ((widget.error ?? '').isNotEmpty) ...[
                  _ErrorBox(
                    message: widget.error!,
                    onRetry: () => setState(() {}), // no-op retry
                  ),
                ] else if (filtered.isEmpty) ...[
                  const _EmptyState(),
                ] else ...[
                  for (final inv in filtered) ...[
                    InkWell(
                      onTap: () {
                        // Navigate by passing the whole object — NO id/API needed.
                        Get.to(
                              () => InvestmentDetailScreen(investment: inv),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: _InvestmentCard(
                        imageUrl: _imageUrl(inv),
                        category: _category(inv),
                        title: _name(inv),
                        description: _description(inv),
                        progressPct: _progressPct(inv),
                        goalUsd: _goal(inv),
                        daysLeft: _daysLeft(inv),
                        ownerAvatar: 'https://i.pravatar.cc/100?img=13', // placeholder
                        ownerName: _ownerName(inv),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Safe helpers (handle mixed shapes without crashing)
  // -------------------------------

  String _name(dynamic inv) {
    try { final v = (inv as dynamic).name; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    try { final v = (inv as dynamic).title; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    return 'Untitled project';
  }

  String _description(dynamic inv) {
    try { final v = (inv as dynamic).description; if (v is String) return v; } catch (_) {}
    return 'No description provided.';
  }

  String _location(dynamic inv) {
    try { final v = (inv as dynamic).location; if (v is String) return v; } catch (_) {}
    return '';
  }

  String _category(dynamic inv) {
    try {
      final v = (inv as dynamic).category;
      if (v is String) return v;
      if (v is List) return v.join(', ');
    } catch (_) {}
    return '';
  }

  String _ownerName(dynamic inv) {
    try { final v = (inv as dynamic).ownerName; if (v is String) return v; } catch (_) {}
    return 'Project Owner';
  }

  String _imageUrl(dynamic inv) {
    try { final v = (inv as dynamic).imageUrl; if (v is String && v.isNotEmpty) return v; } catch (_) {}
    try {
      final images = (inv as dynamic).image;
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is Map && first['url'] is String) return first['url'] as String;
      }
    } catch (_) {}
    try {
      final images = (inv as dynamic).images;
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is Map && first['url'] is String) return first['url'] as String;
        if (first is String) return first;
      }
    } catch (_) {}
    return '';
  }

  int _goal(dynamic inv) {
    try { final v = (inv as dynamic).fundingGoal; if (v is num) return v.toInt(); } catch (_) {}
    try { final v = (inv as dynamic).funding_goal; if (v is num) return v.toInt(); } catch (_) {}
    return 0;
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

  int _progressPct(dynamic inv) {
    try { final v = (inv as dynamic).progressPct; if (v is num) return v.clamp(0, 100).toInt(); } catch (_) {}
    try { final v = (inv as dynamic).progress;    if (v is num) return v.clamp(0, 100).toInt(); } catch (_) {}

    final g = _goal(inv);
    final r = _raised(inv);
    if (g > 0) return ((r / g) * 100).clamp(0, 100).toInt();
    return 0;
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
    if (totalDays == 0) return 0;

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
}

// ---------- small UI widgets ----------

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E23),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String description;
  final int progressPct;
  final int goalUsd;
  final int daysLeft;
  final String ownerAvatar;
  final String ownerName;

  const _InvestmentCard({
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.description,
    required this.progressPct,
    required this.goalUsd,
    required this.daysLeft,
    required this.ownerAvatar,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent = Color(0xFFFF7A1A);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _brokenImage(),
            )
                : _brokenImage(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style:
                    TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                  TextStyle(color: Colors.white.withOpacity(.72), fontSize: 12),
                ),
                const SizedBox(height: 10),

                // progress
                Container(
                  decoration: BoxDecoration(
                    color: inner,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      _ProgressBar(
                        value: (progressPct / 100).clamp(0, 1),
                        color: accent,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '$progressPct% of \$${_fmt(goalUsd)}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(.75), fontSize: 12),
                          ),
                          const Spacer(),
                          Text(
                            '${daysLeft}d left',
                            style: TextStyle(
                                color: Colors.white.withOpacity(.75), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // owner row
                Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundImage: NetworkImage(ownerAvatar)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(ownerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    Container(
                      height: 36,
                      width: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: inner,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.chevron_right, size: 18),
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
    child: const Icon(Icons.broken_image_outlined),
  );
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
              widthFactor: value.clamp(0, 1),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF1B1E23);
    return Container(
      height: 240,
      decoration:
      BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(CupertinoIcons.doc_richtext,
            size: 36, color: Colors.white.withOpacity(.6)),
        const SizedBox(height: 10),
        Text('No investments found',
            style: TextStyle(color: Colors.white.withOpacity(.8))),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF1B1E23);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
      BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Couldn’t load investments',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(.95),
              )),
          const SizedBox(height: 6),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(.75))),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onRetry, child: const Text('Retry')),
          ),
        ],
      ),
    );
  }
}

// — helpers
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
