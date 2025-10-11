// lib/feature/auctions/view/auction_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../app_ground.dart';
import '../../models/auction.dart' as api; // DTOs
import '../../../providers/auction_provider.dart';
import '../../../core/env/env.dart' show AppEnv; // for baseUrl
import 'auction_detail.dart';

enum AuctionStatus { live, upcoming, ended }

class Auction {
  final String id;
  final String title;
  final String imageUrl;
  final int viewers;
  final int interested;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? firstBid;
  final int? finalBid;
  final int? currentPrice;
  final AuctionStatus status;

  const Auction({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    this.viewers = 0,
    this.interested = 0,
    this.startsAt,
    this.endsAt,
    this.firstBid,
    this.finalBid,
    this.currentPrice,
  });
}

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeData.dark();
    return Theme(
      data: dark.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        dividerColor: const Color(0xFF2B2C31),
        colorScheme: dark.colorScheme.copyWith(
          primary: const Color(0xFFFF8C3B),
          secondary: const Color(0xFF2A2B30),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2B30),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2B2C31)),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2B2C31)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF8C3B)),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F10),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      child: const AuctionsScreen(),
    );
  }
}

class AuctionsScreen extends StatefulWidget {
  const AuctionsScreen({super.key});
  @override
  State<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends State<AuctionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _queryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auctions'),
        leading: IconButton(
          onPressed: () => Get.offAll(
                () => const AppGround(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search auctions',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    tooltip: 'Filter',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Hook up your filters here')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _PillTabs(tabController: _tab),
          const SizedBox(height: 6),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                AuctionListView(
                    status: AuctionStatus.live, query: _queryCtrl.text),
                AuctionListView(
                    status: AuctionStatus.upcoming, query: _queryCtrl.text),
                AuctionListView(
                    status: AuctionStatus.ended, query: _queryCtrl.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTabs extends StatelessWidget {
  const _PillTabs({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final third = constraints.maxWidth / 3;

          return Stack(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: cs.secondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: tabController,
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                  unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w700),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: ShapeDecoration(
                    color: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  tabs: const [
                    Tab(text: 'Live Now'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Ended'),
                  ],
                ),
              ),
              Positioned(
                  left: third, top: 6, bottom: 6,
                  child: Container(width: 1, color: border)),
              Positioned(
                  left: third * 2, top: 6, bottom: 6,
                  child: Container(width: 1, color: border)),
            ],
          );
        },
      ),
    );
  }
}

class AuctionListView extends StatefulWidget {
  const AuctionListView({super.key, required this.status, this.query = ''});
  final AuctionStatus status;
  final String query;

  @override
  State<AuctionListView> createState() => _AuctionListViewState();
}

class _AuctionListViewState extends State<AuctionListView> {
  final _scroll = ScrollController();
  final List<Auction> _items = [];
  bool _loading = false;
  bool _end = false;
  int _page = 1;
  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant AuctionListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query || oldWidget.status != widget.status) {
      _load(reset: true);
    }
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
      final prov = context.read<AuctionProvider>();
      final resp = await prov.all(page: _page, limit: _pageSize);

      // Map DTOs -> UI model, then filter by tab + query
      final mapped = resp.auctions
          .map(_mapToUi)
          .where((a) => a.status == widget.status)
          .where((a) => widget.query.isEmpty
          ? true
          : a.title.toLowerCase().contains(widget.query.toLowerCase()))
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

  Future<void> _refresh() => _load(reset: true);

  @override
  Widget build(BuildContext context) {
    final isGrid = widget.status == AuctionStatus.live;

    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isGrid) {
            final cross = constraints.maxWidth > 520 ? 3 : 2;
            return GridView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: _items.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= _items.length) return const _GridLoader();
                return LiveAuctionCard(a: _items[i]);
              },
            );
          } else {
            return ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (i >= _items.length) return const _ListLoader();
                final a = _items[i];
                return widget.status == AuctionStatus.upcoming
                    ? UpcomingAuctionTile(a: a)
                    : EndedAuctionTile(a: a);
              },
            );
          }
        },
      ),
    );
  }

  // ---- mapper & parsers ----
  Auction _mapToUi(api.AuctionDto d) {
    final start = _parseDateTime(d.schedule.date, d.schedule.time);
    final minutes = d.duration ?? 60;
    final end = (start == null) ? null : start.add(Duration(minutes: minutes));

    AuctionStatus statusFromDates() {
      final now = DateTime.now();
      if (start == null || end == null) return AuctionStatus.live;
      if (now.isBefore(start)) return AuctionStatus.upcoming;
      if (now.isAfter(end)) return AuctionStatus.ended;
      return AuctionStatus.live;
    }

    // Prefer API's status when present (your backend returns "upcoming"/"ended"/"live")
    final s = (d.status ?? '').toLowerCase();
    final status = s == 'upcoming'
        ? AuctionStatus.upcoming
        : s == 'ended'
        ? AuctionStatus.ended
        : s == 'live' || s == 'running'
        ? AuctionStatus.live
        : statusFromDates();

    // robust image: support relative URLs and empty payloads
    String rawUrl = '';
    if (d.image.isNotEmpty) {
      rawUrl = d.image.first.url;
    }
    final img =
    _absoluteUrl(rawUrl).isEmpty ? _kPlaceholder : _absoluteUrl(rawUrl);

    return Auction(
      id: d.id,
      title: d.name,
      imageUrl: img,
      status: status,
      startsAt: start,
      endsAt: end,
      firstBid: d.startingBid,
      finalBid: d.startingBid,
      currentPrice: d.startingBid,
      viewers: 0,
      interested: 0,
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
}

// ===== Cards / Tiles (design unchanged) =====

class LiveAuctionCard extends StatelessWidget {
  const LiveAuctionCard({super.key, required this.a});
  final Auction a;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AuctionDetailScreen(auctionId: a.id)),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _NetImage(a.imageUrl),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('LIVE',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x66000000),
                      borderRadius: BorderRadius.circular(18),
                      border:
                      Border.all(color: const Color(0x55FFFFFF), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.visibility, size: 14),
                        SizedBox(width: 4),
                        Text('0'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('\$${a.currentPrice}',
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingAuctionTile extends StatelessWidget {
  const UpcomingAuctionTile({super.key, required this.a});
  final Auction a;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AuctionDetailScreen(auctionId: a.id)),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                height: 80,
                width: 110,
                child: _NetImage(a.imageUrl),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('\$${a.currentPrice}',
                        style: TextStyle(
                            color: cs.primary, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.event, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          a.startsAt == null
                              ? 'TBA'
                              : 'Starts ${_friendlyDate(a.startsAt!)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Spacer(),
                        const Icon(Icons.bookmark_outline_rounded,
                            color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('0 interested',
                        style: TextStyle(color: Colors.white70)),
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

class EndedAuctionTile extends StatelessWidget {
  const EndedAuctionTile({super.key, required this.a});
  final Auction a;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AuctionDetailScreen(auctionId: a.id)),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                height: 80,
                width: 110,
                child: _NetImage(a.imageUrl),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('First Bid: ',
                            style: TextStyle(color: Colors.white70)),
                        Text('\$${a.firstBid}',
                            style:
                            const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        const Text('Final Bid: ',
                            style: TextStyle(color: Colors.white70)),
                        Text('\$${a.finalBid}',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: cs.primary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.lock_clock_rounded,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                            a.endsAt == null
                                ? 'Ended'
                                : 'Ended ${_friendlyDate(a.endsAt!)}',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: Colors.greenAccent),
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

class _GridLoader extends StatelessWidget {
  const _GridLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ListLoader extends StatelessWidget {
  const _ListLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// ===== helpers =====

const String _kPlaceholder =
    'https://via.placeholder.com/640x360.png?text=Auction';

String _absoluteUrl(String url) {
  final u = (url).trim();
  if (u.isEmpty) return '';
  if (u.startsWith('http://') || u.startsWith('https://')) return u;

  // Build absolute from backend base if the server returns relative paths
  final base = AppEnv.baseUrl;
  if (base.isEmpty) return u;
  if (base.endsWith('/') && u.startsWith('/')) return '$base${u.substring(1)}';
  if (!base.endsWith('/') && !u.startsWith('/')) return '$base/$u';
  return '$base$u';
}

String _friendlyDate(DateTime d) {
  final now = DateTime.now();
  final dayDiff = d.difference(now).inDays;
  if (dayDiff >= 1) {
    if (dayDiff == 1) return 'Tomorrow, ${_timeOf(d)}';
    return '${_weekday(d)}, ${_timeOf(d)}';
  } else if (dayDiff == 0) {
    return 'Today, ${_timeOf(d)}';
  } else {
    final ended = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (ended == 0) return 'today';
    if (ended == 1) return 'yesterday';
    return '${d.month}/${d.day}';
  }
}

String _weekday(DateTime d) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[d.weekday - 1];
}

String _timeOf(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ampm';
}

/// Small image widget that won’t break layout if URL is bad.
class _NetImage extends StatelessWidget {
  final String url;
  const _NetImage(this.url);

  @override
  Widget build(BuildContext context) {
    final u = url.isEmpty ? _kPlaceholder : url;
    return Image.network(
      u,
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0x11000000),
          child:
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (ctx, _, __) {
        return Container(
          color: const Color(0x11000000),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined,
              size: 28, color: Colors.white70),
        );
      },
    );
  }
}
