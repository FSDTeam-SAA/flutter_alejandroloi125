// lib/feature/event/my_event_auction/my_event_auction.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auction_provider.dart';
import '../../../models/auction.dart';
import 'my_event_aution_details.dart';

const _bg     = Color(0xFF0E0E10);
const _card   = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);

class MyEventAuction extends StatefulWidget {
  const MyEventAuction({super.key});

  @override
  State<MyEventAuction> createState() => _MyEventAuctionState();
}

class _MyEventAuctionState extends State<MyEventAuction> {
  late Future<AuctionListResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuctionProvider>().all(page: 1, limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      body: FutureBuilder<AuctionListResponse>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${snap.error}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final data = snap.data;
          final items = data?.auctions ?? const <AuctionDto>[];
          if (items.isEmpty) {
            return const Center(
              child: Text('No auctions found', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final auc = items[i];
              return _AuctionCard(
                auc: auc,
                onTap: () => Get.to(
                      () => MyEventAutionDetailScreen(auctionId: auc.id),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 320),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final AuctionDto auc;
  final VoidCallback? onTap;
  const _AuctionCard({required this.auc, this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumb = (auc.image.isNotEmpty ? auc.image.first.url : '').trim();
    final title = auc.name.trim().isEmpty ? '-' : auc.name.trim();
    final finalBid = auc.startingBid;
    final status = _statusOf(auc); // "Live" / "Ended" (you can wire real statuses if API provides)
    final endedText = _endedText(auc.schedule.date); // "Ended jun 10"
    final pill = _pillStyle(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // ---- LEFT THUMB 1:1 ----
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 120,
                height: 90,
                child: AspectRatio(
                  aspectRatio: 1, // square
                  child: thumb.isEmpty
                      ? Container(color: Colors.white10)
                      : Image.network(thumb, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ---- RIGHT CONTENT ----
            Expanded(
              child: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status pill
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: pill.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: pill.fg,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Final Bid row
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Final Bid: ',
                            style: TextStyle(color: Colors.white, fontSize: 13.5),
                          ),
                          TextSpan(
                            text: '\$${_comma(finalBid)}',
                            style: const TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Ended row
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(endedText, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------- helpers --------

class _PillStyle {
  final Color bg;
  final Color fg;
  const _PillStyle(this.bg, this.fg);
}

_PillStyle _pillStyle(String status) {
  switch (status.toLowerCase()) {
    case 'won':
      return const _PillStyle(Color(0x332AA86F), Color(0xFF2AA86F)); // soft green
    case 'live':
      return const _PillStyle(Color(0xFFE53935), Colors.white); // red
    case 'loss':
      return const _PillStyle(Color(0xFFE53935), Colors.white); // red
    case 'ended':
    default:
      return const _PillStyle(Color(0x33424242), Colors.white70); // gray
  }
}

// Very simple status guesser (replace with real field if your API sends one)
String _statusOf(AuctionDto a) {
  // If you later add `a.status`, just return it here.
  final dt = _parseDdMmYyyy(a.schedule.date);
  if (dt == null) return 'Ended';
  return DateTime.now().isBefore(dt.add(const Duration(hours: 24))) ? 'Live' : 'Ended';
}

String _endedText(String ddMmYyyy) {
  final dt = _parseDdMmYyyy(ddMmYyyy);
  if (dt == null) return 'Ended';
  final m = _mon(dt.month).toLowerCase();
  return 'Ended $m ${dt.day}';
}

DateTime? _parseDdMmYyyy(String s) {
  // expects "dd-MM-yyyy"
  final p = s.split('-');
  if (p.length != 3) return null;
  final d = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  final y = int.tryParse(p[2]);
  if (d == null || m == null || y == null) return null;
  return DateTime(y, m, d);
}

String _mon(int m) =>
    const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

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
