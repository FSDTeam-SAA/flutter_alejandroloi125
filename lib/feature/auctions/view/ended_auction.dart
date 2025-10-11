// lib/feature/auctions/view/ended_auction_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auction_provider.dart';
import '../../models/auction.dart' as api;
import '../../../core/env/env.dart' show AppEnv;
import '../../../core/util/app_colors.dart';
import 'auction_detail.dart';

class EndedAuctionView extends StatefulWidget {
  const EndedAuctionView({super.key});

  @override
  State<EndedAuctionView> createState() => _EndedAuctionViewState();
}

class _EndedAuctionViewState extends State<EndedAuctionView> {
  final _scroll = ScrollController();
  bool _loading = false;
  bool _end = false;
  int _page = 1;
  static const _pageSize = 12;

  final List<_EndedVm> _items = [];

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_end || _loading) return;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);

    if (reset) {
      _page = 1;
      _end = false;
      _items.clear();
    }

    try {
      final resp = await context
          .read<AuctionProvider>()
          .all(page: _page, limit: _pageSize);

      final mapped = resp.auctions
          .map(_map)
          .where((v) => v.status == _EndedStatus.ended)
          .toList();

      setState(() {
        _items.addAll(mapped);
        _page++;
        _end = (_page > resp.pages) || mapped.isEmpty;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  _EndedVm _map(api.AuctionDto d) {
    final start = _parseDateTime(d.schedule.date, d.schedule.time);
    final end =
    (start == null) ? null : start.add(Duration(minutes: d.duration ?? 60));
    final now = DateTime.now();
    final status = (start == null || end == null)
        ? _EndedStatus.ended
        : now.isAfter(end)
        ? _EndedStatus.ended
        : _EndedStatus.other;

    final img =
    _absolute(d.image.isNotEmpty ? d.image.first.url : '').isEmpty
        ? 'https://via.placeholder.com/640x640.png?text=Auction'
        : _absolute(d.image.first.url);

    return _EndedVm(
      id: d.id,
      name: d.name,
      startingBid: d.startingBid,
      imageUrl: img,
      endedAt: end,
      status: status,
    );
  }

  DateTime? _parseDateTime(String ddMMyyyy, String hhmm) {
    try {
      final ds = ddMMyyyy.split('-');
      if (ds.length != 3) return null;
      final d = int.parse(ds[0]);
      final m = int.parse(ds[1]);
      final y = int.parse(ds[2]);
      var t = hhmm.trim().toUpperCase();
      final hasAmPm = t.endsWith('AM') || t.endsWith('PM');
      t = t.replaceAll('AM', '').replaceAll('PM', '').trim();
      final ts = t.split(':');
      final hRaw = int.parse(ts[0]);
      final min = ts.length > 1 ? int.parse(ts[1]) : 0;
      var hour = hRaw;
      if (hasAmPm && hhmm.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (hasAmPm && hhmm.toUpperCase().contains('AM') && hour == 12) hour = 0;
      return DateTime(y, m, d, hour, min);
    } catch (_) {
      return null;
    }
  }

  String _absolute(String url) {
    final u = url.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppEnv.baseUrl;
    if (base.isEmpty) return u;
    if (base.endsWith('/') && u.startsWith('/')) return '$base${u.substring(1)}';
    if (!base.endsWith('/') && !u.startsWith('/')) return '$base/$u';
    return '$base$u';
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _loading) {
      return const Center(
        child: CircularProgressIndicator(backgroundColor: Colors.white),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'No ended auctions found',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        controller: _scroll,
        itemCount: _items.length + (_loading ? 1 : 0),
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final auction = _items[index];

          return Card(
            color: Theme.of(context).cardColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        AuctionDetailScreen(auctionId: auction.id)));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        auction.imageUrl,
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 108,
                          height: 108,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auction.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Text("First Bid: ",
                                  style: TextStyle(color: Colors.white70)),
                              Text("\$${auction.startingBid}",
                                  style: TextStyle(
                                    color: AppColors.bottomColor1,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 2),

                          Row(
                            children: const [
                              Text("Final Bid: ",
                                  style: TextStyle(color: Colors.white70)),
                              // If you later have an ending bid field, show it here.
                            ],
                          ),
                          const SizedBox(height: 2),

                          Row(
                            children: [
                              const Icon(Icons.watch_later_outlined,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                auction.endedAt == null
                                    ? 'Ended'
                                    : 'Ended: ${auction.endedAt!.day.toString().padLeft(2, '0')}-'
                                    '${auction.endedAt!.month.toString().padLeft(2, '0')}-'
                                    '${auction.endedAt!.year}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _EndedStatus { ended, other }

class _EndedVm {
  final String id;
  final String name;
  final int startingBid;
  final String imageUrl;
  final DateTime? endedAt;
  final _EndedStatus status;

  _EndedVm({
    required this.id,
    required this.name,
    required this.startingBid,
    required this.imageUrl,
    required this.endedAt,
    required this.status,
  });
}
