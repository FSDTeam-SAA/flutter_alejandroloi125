// lib/feature/auction/view/my_auction_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_auction_details.dart';

class MyAuctionScreen extends StatefulWidget {
  const MyAuctionScreen({super.key});
  @override
  State<MyAuctionScreen> createState() => _MyAuctionScreenState();
}

class _MyAuctionScreenState extends State<MyAuctionScreen> {
  final _scroll = ScrollController();

  // local-only state (no API / provider)
  bool _loading = true;
  bool _paging = false;
  String? _error;

  int _page = 1;
  final int _pages = 3; // total pages in this local demo
  final int _limit = 10;

  final List<_Auction> _items = [];

  @override
  void initState() {
    super.initState();
    // initial load
    _fetch(page: 1, limit: _limit);

    // infinite scroll
    _scroll.addListener(() {
      if (_paging || _loading) return;
      final nearBottom = _scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 120;
      if (nearBottom && _page < _pages) {
        _paging = true;
        _fetch(page: _page + 1, limit: _limit).whenComplete(() {
          _paging = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // local "fetch" that generates mock data
  Future<void> _fetch({required int page, required int limit}) async {
    try {
      if (page == 1) setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 350)); // simulate work

      final newItems = _makeFakePage(page, limit);
      setState(() {
        if (page == 1) _items.clear();
        _items.addAll(newItems);
        _page = page;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load auctions';
      });
    }
  }

  // local delete
  Future<void> _delete(String id) async {
    setState(() => _items.removeWhere((a) => a.id == id));
    Get.snackbar('Deleted', 'Auction removed',
        snackPosition: SnackPosition.TOP);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: Builder(builder: (_) {
          if (_loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if ((_error ?? '').isNotEmpty && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, style: const TextStyle(color: Colors.white70)),
              ),
            );
          }
          if (items.isEmpty) {
            return const Center(
              child: Text('No auctions found',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: items.length + (_page < _pages ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              if (i >= items.length) {
                // paging loader
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final a = items[i];
              final price = (a.startingBid == null)
                  ? '-'
                  : '\$${_comma(a.startingBid!)}';
              final time = _timeLabel(a.scheduleDate, a.scheduleTime, a.fundingDuration);

              return _AuctionCard.dynamic(
                imageUrl: a.cover ?? 'assets/images/watch.jpg',
                title: a.name,
                priceLabel: price,
                timeLabel: time,
                status: 'In Progress',
                statusColor: const Color(0xFFFF8A34),
                completed: false,
                onView: () {
                  Get.to(
                        () => MyAuctionDetailScreen(auctionId: a.id),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                onDelete: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete auction?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  ) ??
                      false;
                  if (!ok) return;
                  await _delete(a.id);
                },
              );
            },
          );
        }),
      ),
    );
  }

  // ---- mock data helpers ----
  List<_Auction> _makeFakePage(int page, int limit) {
    return List.generate(limit, (i) {
      final num = (page - 1) * limit + i + 1;
      return _Auction(
        id: 'auction_$num',
        name: 'Auction #$num',
        startingBid: (num % 3 == 0) ? null : 1000 + num * 25,
        fundingDuration: (num % 4 == 0)
            ? '1h'
            : (num % 3 == 0)
            ? '30m'
            : (num % 2 == 0)
            ? '20m'
            : '10m',
        scheduleDate: (num % 5 == 0) ? null : '25-08-2025',
        scheduleTime: (num % 2 == 0) ? '8:25' : '3:00 PM',
        cover: null, // uses default asset
      );
    });
  }
}

// ==== simple local model (only fields used by the UI) ====
class _Auction {
  final String id;
  final String name;
  final int? startingBid;
  final String fundingDuration;
  final String? scheduleDate;
  final String? scheduleTime;
  final String? cover;

  _Auction({
    required this.id,
    required this.name,
    required this.startingBid,
    required this.fundingDuration,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.cover,
  });
}

// ==== helpers + card (same visuals you already had) ====
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

String _timeLabel(String? d, String? t, String duration) {
  final dd = (d ?? '').trim();
  final tt = (t ?? '').trim();
  if (dd.isEmpty && tt.isEmpty) return duration.isEmpty ? '-' : duration;
  return '$dd ${tt.isEmpty ? '' : tt}';
}

class _AuctionCard extends StatelessWidget {
  final String imageUrl, title, priceLabel, timeLabel, status;
  final Color statusColor;
  final bool completed;
  final VoidCallback? onView, onDelete;

  const _AuctionCard.dynamic({
    required this.imageUrl,
    required this.title,
    required this.priceLabel,
    required this.timeLabel,
    required this.status,
    required this.statusColor,
    required this.completed,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl.startsWith('http')
                    ? Image.network(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _broken())
                    : Image.asset(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _broken()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(priceLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600)),
                        ]),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.7)),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 10),
                _InfoBar(icon: Icons.access_time, label: timeLabel),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.15)),
                        foregroundColor: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onDelete,
                      child: const Text('Delete'),
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
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _broken() => Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined));
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
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
