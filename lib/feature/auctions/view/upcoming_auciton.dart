// lib/feature/auctions/view/upcoming_auction_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import '../../../providers/auction_provider.dart';
import '../../models/auction.dart' as api;
import '../../../core/env/env.dart' show AppEnv;
import 'auction_detail.dart';

class UpcomingAuctionsView extends StatefulWidget {
  const UpcomingAuctionsView({super.key});

  @override
  State<UpcomingAuctionsView> createState() => _UpcomingAuctionsViewState();
}

class _UpcomingAuctionsViewState extends State<UpcomingAuctionsView> {
  final _scroll = ScrollController();
  bool _loading = false;
  bool _end = false;
  int _page = 1;
  static const _pageSize = 12;

  final List<_UpcomingVm> _items = [];

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
          .where((v) => v.status == _UpcomingStatus.upcoming)
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

  _UpcomingVm _map(api.AuctionDto d) {
    final start = _parseDateTime(d.schedule.date, d.schedule.time);
    final end =
    (start == null) ? null : start.add(Duration(minutes: d.duration ?? 60));
    final now = DateTime.now();
    final status = (start == null || end == null)
        ? _UpcomingStatus.live
        : now.isBefore(start)
        ? _UpcomingStatus.upcoming
        : (now.isAfter(end) ? _UpcomingStatus.ended : _UpcomingStatus.live);

    final img =
    _absolute(d.image.isNotEmpty ? d.image.first.url : '').isEmpty
        ? 'https://via.placeholder.com/400x400.png?text=Auction'
        : _absolute(d.image.first.url);

    return _UpcomingVm(
      id: d.id,
      name: d.name,
      description: d.description,
      startingBid: d.startingBid,
      imageUrl: img,
      date: d.schedule.date,
      time: d.schedule.time,
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No upcoming auctions'));
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        controller: _scroll,
        itemCount: _items.length + (_loading ? 1 : 0),
        itemBuilder: (_, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final auction = _items[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        AuctionDetailScreen(auctionId: auction.id)));
              },
              child: Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
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
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 108),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            auction.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white),
                          ),
                        ),
                        Row(
                          children: [
                            const Text("First Bid : "),
                            Text("\$ ${auction.startingBid}",
                                style:
                                TextStyle(color: AppColors.bottomColor1)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Final Bid : "),
                            Text("\$ ${auction.startingBid}",
                                style:
                                TextStyle(color: AppColors.bottomColor1)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.watch_later_outlined),
                            Text(" Starts :${auction.date}"),
                          ],
                        ),
                      ],
                    )
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

enum _UpcomingStatus { live, upcoming, ended }

class _UpcomingVm {
  final String id;
  final String name;
  final String description;
  final int startingBid;
  final String imageUrl;
  final String date;
  final String time;
  final _UpcomingStatus status;

  _UpcomingVm({
    required this.id,
    required this.name,
    required this.description,
    required this.startingBid,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.status,
  });
}
