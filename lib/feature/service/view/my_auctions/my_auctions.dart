// lib/feature/auction/view/my_auction_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_auction_details.dart';

/// Local-only version (no Provider/API).
/// Pass pre-fetched [auctions], and optionally toggle [loading]/[error].
class MyAuctionScreen extends StatefulWidget {
  const MyAuctionScreen({
    super.key,
    this.auctions = const <AuctionItem>[],
    this.loading = false,
    this.error,
    this.onDelete, // optional callback if you still want to hook into something external
  });

  final List<AuctionItem> auctions;
  final bool loading;
  final String? error;

  /// Optional: will be invoked after a local delete succeeds.
  final Future<void> Function(String id)? onDelete;

  @override
  State<MyAuctionScreen> createState() => _MyAuctionScreenState();
}

class _MyAuctionScreenState extends State<MyAuctionScreen> {
  late List<AuctionItem> _items;
  final Set<String> _deleting = {};

  @override
  void initState() {
    super.initState();
    _items = List<AuctionItem>.from(widget.auctions);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading && _items.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0F12),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (widget.error != null && _items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0F12),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.error!, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  const Text('No auctions to show', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0F12),
        body: SafeArea(
          child: Center(
            child: Text('No auctions found', style: TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final a = _items[i];
            final priceLabel = a.startingBid != null ? '\$${_comma(a.startingBid!)}' : '-';
            final timeLabel = _timeLabel(a);
            const status = 'In Progress';
            const statusColor = Color(0xFFFF8A34);

            return _AuctionCard.dynamic(
              imageUrl: a.imageUrl ?? 'assets/images/watch.jpg',
              title: a.name ?? 'Auction',
              priceLabel: priceLabel,
              timeLabel: timeLabel,
              status: status,
              statusColor: statusColor,
              completed: false,
              deleting: a.id != null && _deleting.contains(a.id),
              onView: (a.id == null || a.id!.isEmpty)
                  ? null
                  : () {
                Get.to(
                      () => MyAuctionDetailScreen(auctionId: a.id!),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onDelete: (a.id == null)
                  ? null
                  : () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete auction?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ??
                    false;
                if (!ok) return;

                setState(() => _deleting.add(a.id!));
                // Local-only delete
                await Future.delayed(const Duration(milliseconds: 350));
                setState(() {
                  _items.removeWhere((e) => e.id == a.id);
                  _deleting.remove(a.id);
                });

                // Optionally notify upstream
                if (widget.onDelete != null) {
                  await widget.onDelete!(a.id!);
                }

                Get.snackbar('Deleted', 'Auction removed',
                    snackPosition: SnackPosition.TOP);
              },
            );
          },
        ),
      ),
    );
  }
}

/// Local, minimal auction model for this screen (no API/provider).
class AuctionItem {
  final String? id;
  final String? name;
  final int? startingBid; // in USD
  final String? scheduleDate; // e.g., "2025-10-10"
  final String? scheduleTime; // e.g., "15:30"
  final int? duration; // minutes
  final String? imageUrl; // optional override for card image

  const AuctionItem({
    this.id,
    this.name,
    this.startingBid,
    this.scheduleDate,
    this.scheduleTime,
    this.duration,
    this.imageUrl,
  });
}

// ---------- helpers ----------
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

String _timeLabel(AuctionItem a) {
  final date = (a.scheduleDate ?? '').trim();
  final time = (a.scheduleTime ?? '').trim();
  if (date.isEmpty && time.isEmpty) {
    final dur = a.duration;
    if (dur is int) {
      if (dur >= 60) {
        final h = dur ~/ 60;
        return '${h}h auction';
      }
      return '${dur}m auction';
    }
    return 'No schedule';
  }
  return '$date ${time.isEmpty ? '' : time}';
}

// ---- card (kept design) ----
class _AuctionCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String priceLabel;
  final String timeLabel;
  final String status;
  final Color statusColor;
  final bool completed;
  final VoidCallback? onView;
  final VoidCallback? onDelete;
  final bool deleting;

  const _AuctionCard.dynamic({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.priceLabel,
    required this.timeLabel,
    required this.status,
    required this.statusColor,
    required this.completed,
    this.onView,
    this.onDelete,
    this.deleting = false,
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
          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
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
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _broken(),
                )
                    : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _broken(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.7)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoBar(icon: Icons.access_time, label: timeLabel),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          foregroundColor: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: deleting ? null : onDelete,
                        child: deleting
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  Widget _broken() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined),
  );
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
              overflow: TextOverflow.ellipsis,
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
