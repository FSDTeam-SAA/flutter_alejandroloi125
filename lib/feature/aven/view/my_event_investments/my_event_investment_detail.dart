import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../../../providers/investment_provider.dart';
import '../../../models/investment.dart';

const _accent = Color(0xFFFF7A00);

class InvestmentDetails extends StatefulWidget {
  final String investmentId;
  const InvestmentDetails({super.key, required this.investmentId});

  @override
  State<InvestmentDetails> createState() => _InvestmentDetailsState();
}

class _InvestmentDetailsState extends State<InvestmentDetails> {
  Investment? _inv;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _loading = true);
      try {
        final inv =
        await context.read<InvestmentProvider>().getById(widget.investmentId);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, style: const TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }
    if (_inv == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Investment not found', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final i = _inv!;
    final pct = i.progressPct.clamp(0, 100);
    final goalStr = i.fundingGoal == null ? '-' : '\$${_comma(i.fundingGoal!)}';
    final daysLeft = i.daysLeft ?? _parseDays(i.fundingDuration);

    // NEW: extract investors defensively (won’t crash if field doesn’t exist)
    final investors = _extractInvestors(i);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Investments Details', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverHeader(i.primaryImageUrl),

            const SizedBox(height: 10),
            const Text('Agriculture',
                style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),

            Text(i.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(i.description, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
            const SizedBox(height: 10),

            if (i.location.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.place, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text(i.location, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                ]),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                _StatCell(title: '$pct%', subtitle: 'of $goalStr'),
                _DividerDot(),
                _StatCell(title: '—', subtitle: 'Backers'),
                _DividerDot(),
                _StatCell(title: daysLeft == null ? '-' : '$daysLeft', subtitle: 'Days left'),
              ],
            ),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct / 100.0,
                minHeight: 6,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(_accent),
              ),
            ),
            const SizedBox(height: 14),

            const Text('About This Project',
                style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(i.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45)),
            const SizedBox(height: 14),

            if (i.images.isNotEmpty) ...[
              const Text('Gallery',
                  style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: i.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final img = i.images[idx].url;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(img, width: 140, height: 90, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Investment Terms',
                style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(i.investmentTerms.isEmpty ? '—' : i.investmentTerms,
                style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45)),

            // NEW: Investors list (red box in your mock)
            if (investors.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('Investor',
                  style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Column(
                children: investors.map((iv) => _InvestorTile(iv)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoverHeader extends StatelessWidget {
  final String? url;
  const _CoverHeader(this.url);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url == null || url!.isEmpty
                ? Container(color: Colors.white10)
                : Image.network(url!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _round(ActionIcon.back, () => Get.back()),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(children: [
            _round(ActionIcon.share, () {}),
            const SizedBox(width: 8),
            _round(ActionIcon.heart, () {}),
          ]),
        ),
      ],
    );
  }

  Widget _round(ActionIcon icon, VoidCallback onTap) {
    final data = {
      ActionIcon.back: Icons.arrow_back,
      ActionIcon.share: Icons.ios_share_outlined,
      ActionIcon.heart: Icons.favorite_border,
    }[icon]!;
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        height: 32,
        width: 32,
        decoration:
        BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
        child: Icon(data, color: Colors.white, size: 18),
      ),
    );
  }
}

enum ActionIcon { back, share, heart }

class _StatCell extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StatCell({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}

class _DividerDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(width: 16);
}

// -----------------------------------------------------------------------------
// NEW: Investor section (defensive extraction + tile UI)
// -----------------------------------------------------------------------------

class _Investor {
  final String name;
  final String avatarUrl;
  final int amount;
  final String? when;

  _Investor({
    required this.name,
    required this.avatarUrl,
    required this.amount,
    this.when,
  });

  factory _Investor.fromMap(Map<String, dynamic> m) {
    // nested user object (common)
    final user = (m['user'] is Map) ? Map<String, dynamic>.from(m['user']) : <String, dynamic>{};

    String _pickName(Map<String, dynamic> mm) =>
        (mm['fullName'] ??
            mm['name'] ??
            mm['username'] ??
            (user['fullName'] ?? user['name'] ?? user['username']) ??
            '—')
            .toString();

    String _pickAvatar(Map<String, dynamic> mm) =>
        (mm['avatar'] ??
            mm['image'] ??
            mm['photo'] ??
            user['avatar'] ??
            user['image'] ??
            user['photo'] ??
            '')
            .toString();

    int _pickAmount(Map<String, dynamic> mm) {
      final keys = ['amount', 'investment_amount', 'value', 'investAmount', 'invested', 'price'];
      for (final k in keys) {
        final v = mm[k];
        final n = _asInt(v);
        if (n != null) return n;
      }
      return 0;
    }

    String? _pickWhen(Map<String, dynamic> mm) =>
        (mm['createdAt'] ?? mm['date'] ?? mm['time'] ?? '').toString().trim().isEmpty
            ? null
            : (mm['createdAt'] ?? mm['date'] ?? mm['time']).toString();

    return _Investor(
      name: _pickName(m),
      avatarUrl: _pickAvatar(m),
      amount: _pickAmount(m),
      when: _pickWhen(m),
    );
  }
}

class _InvestorTile extends StatelessWidget {
  final _Investor data;
  const _InvestorTile(this.data);

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1F2023);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _Avatar(url: data.avatarUrl, name: data.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(
                    child: Text(data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ),
                  if (data.when != null)
                    Text(data.when!,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Investment Amount:',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 8),
          Text('\$${_comma(data.amount)}',
              style: const TextStyle(
                  color: _accent, fontSize: 13.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String name;
  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return CircleAvatar(radius: 18, backgroundImage: NetworkImage(url));
    }
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white12,
      child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

// ---------- helpers ----------

int? _parseDays(String? s) {
  if (s == null) return null;
  final m = RegExp(r'\d+').firstMatch(s);
  return m == null ? null : int.tryParse(m.group(0)!);
}

int? _asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

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

// ---------- robust investor extraction (NO crashes if field missing) ----------
List<_Investor> _extractInvestors(Investment inv) {
  final d = inv as dynamic;

  // Safely try to read a list property by name
  List? _tryProp(String name) {
    try {
      switch (name) {
        case 'investors':
          final v = d.investors;
          return (v is List) ? v : null;
        case 'backers':
          final v = d.backers;
          return (v is List) ? v : null;
        case 'investments':
          final v = d.investments;
          return (v is List) ? v : null;
        case 'funders':
          final v = d.funders;
          return (v is List) ? v : null;
        case 'supporters':
          final v = d.supporters;
          return (v is List) ? v : null;
      }
    } catch (_) {}
    return null;
  }

  // 1) Try common dynamic properties on the model instance
  List? list = _tryProp('investors') ??
      _tryProp('backers') ??
      _tryProp('investments') ??
      _tryProp('funders') ??
      _tryProp('supporters');

  // 2) If model exposes toJson(), read from that map
  if (list == null) {
    try {
      final j = d.toJson();
      if (j is Map) {
        List? pick(String k) {
          final v = j[k];
          return (v is List) ? v : null;
        }

        list = pick('investors') ??
            pick('backers') ??
            pick('investments') ??
            pick('funders') ??
            pick('supporters');
      }
    } catch (_) {}
  }

  // 3) If the object itself is a Map (edge case)
  if (list == null && d is Map) {
    final m = Map<String, dynamic>.from(d);
    List? pick(String k) {
      final v = m[k];
      return (v is List) ? v : null;
    }
    list = pick('investors') ??
        pick('backers') ??
        pick('investments') ??
        pick('funders') ??
        pick('supporters');
  }

  // Normalize list → _Investor
  final safe = (list ?? const [])
      .whereType<Map>()
      .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
      .map(_Investor.fromMap)
      .toList();

  return safe;
}
