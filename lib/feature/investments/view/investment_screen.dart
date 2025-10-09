import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../providers/investment_provider.dart';
import '../../models/investment.dart';
import '../../app_ground.dart';
import 'investment_detail.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentProvider>().fetch(page: 1, limit: 10);
    });
  }

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

    final prov = context.watch<InvestmentProvider>();
    final itemsAll = prov.items; // List<Investment>
    final query = _searchCtl.text.trim().toLowerCase();

    final filtered = itemsAll.where((inv) {
      final name = inv.name.toLowerCase();
      final loc  = inv.location.toLowerCase();
      final cat  = inv.category.join(', ').toLowerCase();
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
            onRefresh: () => prov.fetch(page: 1, limit: 10),
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
                    const Text('Investments',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
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
                        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.search, color: Colors.white.withOpacity(.7), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search name or location',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 14),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (query.isNotEmpty)
                              GestureDetector(
                                onTap: () { _searchCtl.clear(); setState(() {}); },
                                child: Icon(CupertinoIcons.clear_thick_circled,
                                    size: 18, color: Colors.white.withOpacity(.6)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _IconBtn(onTap: () {}, child: const Icon(CupertinoIcons.slider_horizontal_3, size: 18)),
                  ],
                ),
                const SizedBox(height: 14),

                // Content
                if (prov.loading) ...[
                  const _ShimmerCard(), const SizedBox(height: 14),
                  const _ShimmerCard(), const SizedBox(height: 14),
                  const _ShimmerCard(),
                ] else if ((prov.error ?? '').isNotEmpty) ...[
                  _ErrorBox(message: prov.error!, onRetry: () => prov.fetch(page: 1, limit: 10)),
                ] else if (filtered.isEmpty) ...[
                  const _EmptyState(),
                ] else ...[
                  for (final inv in filtered) ...[
                    InkWell(
                      onTap: () {
                        Get.to(
                              () => InvestmentDetailScreen(investmentId: inv.id,   // required
                                prefetched: inv,  ),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: _InvestmentCard(
                        imageUrl: inv.primaryImageUrl ?? '',
                        category: inv.category.join(', '),
                        title: inv.name,
                        description: inv.description,
                        progressPct: _progress(inv),
                        goalUsd: inv.fundingGoal ?? 0,
                        daysLeft: _daysLeft(inv),
                        ownerAvatar: 'https://i.pravatar.cc/100?img=13',
                        ownerName: 'John Smith', // replace when backend adds owner
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

  // ----- helpers adapted to the new model -----
  int _progress(Investment x) => x.progressPct;

  int _daysLeft(Investment x) {
    final s = (x.fundingDuration ?? '').toLowerCase().trim();
    if (s.isEmpty) return 0;

    final numMatch = RegExp(r'\d+').firstMatch(s)?.group(0);
    final n = int.tryParse(numMatch ?? '');
    if (n == null) return 0;

    if (s.contains('month')) return n * 30;
    if (s.contains('week'))  return n * 7;
    if (s.contains('day'))   return n;
    return n; // assume days if unit missing
  }
}

// ---------- UI pieces (unchanged) ----------
class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      height: 40, width: 40,
      decoration: BoxDecoration(color: const Color(0xFF1B1E23), borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: child,
    ),
  );
}

class _InvestmentCard extends StatelessWidget {
  final String imageUrl, category, title, description, ownerAvatar, ownerName;
  final int progressPct, goalUsd, daysLeft;
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
    const card  = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent= Color(0xFFFF7A1A);
    return Container(
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: imageUrl.isNotEmpty
              ? Image.network(imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _brokenImage())
              : _brokenImage(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(category, style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 12)),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(color: inner, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(children: [
                _ProgressBar(value: (progressPct / 100).clamp(0, 1).toDouble(), color: accent),
                const SizedBox(height: 6),
                Row(children: [
                  Text('$progressPct% of \$${_fmt(goalUsd)}',
                      style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 12)),
                  const Spacer(),
                  Text('${daysLeft}d left',
                      style: TextStyle(color: Colors.white.withOpacity(.75), fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 10),

            Row(children: [
              CircleAvatar(radius: 14, backgroundImage: NetworkImage(ownerAvatar)),
              const SizedBox(width: 8),
              Expanded(child: Text(ownerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
              Container(
                height: 36, width: 36, alignment: Alignment.center,
                decoration: BoxDecoration(color: inner, borderRadius: BorderRadius.circular(10)),
                child: const Icon(CupertinoIcons.chevron_right, size: 18),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _brokenImage() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined),
  );
}

class _ProgressBar extends StatelessWidget {
  final double value; final Color color;
  const _ProgressBar({required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(.12);
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(children: [
          Container(color: bg),
          FractionallySizedBox(widthFactor: value.clamp(0, 1), child: Container(color: color)),
        ]),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 240, decoration: BoxDecoration(color: const Color(0xFF1B1E23), borderRadius: BorderRadius.circular(14)));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 40),
    Icon(CupertinoIcons.doc_richtext, size: 36, color: Colors.white.withOpacity(.6)),
    const SizedBox(height: 10),
    Text('No investments found', style: TextStyle(color: Colors.white.withOpacity(.8))),
  ]);
}

class _ErrorBox extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorBox({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF1B1E23), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Couldn’t load investments',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white.withOpacity(.95))),
      const SizedBox(height: 6),
      Text(message, style: TextStyle(color: Colors.white.withOpacity(.75))),
      const SizedBox(height: 10),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: onRetry, child: const Text('Retry'))),
    ]),
  );
}

// format helper
String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final left = s.length - i - 1;
    buf.write(s[i]);
    if (left % 3 == 0 && left != 0) buf.write(',');
  }
  return buf.toString();
}
