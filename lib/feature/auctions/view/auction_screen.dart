// lib/feature/auctions/view/auction_screen.dart

/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_service/token_store.dart';
import '../../app_ground.dart';
import '../controller/auction_controller.dart';
import '../model/auction_model.dart';
import '../repo/auction_repo.dart';

import '../../../core/network/api_service/api_client.dart';
import '../services/auctions_services.dart';

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Initialize repository & controller ---
    final tokenStore = TokenStore();
    final apiClient = ApiClient(tokenStore); // তোমার ApiClient instance
    final repository = AuctionRepository(AuctionService(apiClient));
    final controller = Get.put(AuctionController(repository));

    final dark = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark.copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        dividerColor: const Color(0xFF2B2C31),
        colorScheme: dark.colorScheme.copyWith(
          primary: const Color(0xFFFF8C3B),
          secondary: const Color(0xFF2A2B30),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auctions'),
          leading: IconButton(
            onPressed: () => Get.offAll(
                  () => const AppGround(),
              transition: Transition.rightToLeft,
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.error.value.isNotEmpty) {
            return Center(child: Text(controller.error.value));
          } else if (controller.allAuctions.isEmpty) {
            return const Center(child: Text('No auctions found'));
          } else {
            return ListView.builder(
              itemCount: controller.allAuctions.length,
              itemBuilder: (context, index) {
                final item = controller.allAuctions[index];
                return AuctionTile(item: item);
              },
            );
          }
        }),
      ),
    );
  }
}

class AuctionTile extends StatelessWidget {
  final AuctionItem item;
  const AuctionTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: item.image.isNotEmpty
            ? Image.network(item.image[0].url, width: 60, fit: BoxFit.cover)
            : const Icon(Icons.image_not_supported),
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text('\$${item.startingBid}', style: const TextStyle(color: Colors.orangeAccent)),
      ),
    );
  }
}*/

import 'dart:async';
import 'package:alejandroloi/feature/auctions/view/auction_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../../../core/network/api_service/api_client.dart';
import '../../../core/network/api_service/token_store.dart';
import '../../app_ground.dart';
import '../controller/auction_controller.dart';
import '../repo/auction_repo.dart';
import '../services/auctions_services.dart';
import 'ended_auction.dart';
import 'upcoming_auciton.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  @override
  Widget build(BuildContext context) {
    final dark = ThemeData.dark();
    return MaterialApp(
      title: 'Auctions',
      debugShowCheckedModeBanner: false,
      theme: dark.copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        dividerColor: const Color(0xFF2B2C31),
        colorScheme: dark.colorScheme.copyWith(
          primary: const Color(0xFFFF8C3B), // orange accent
          secondary: const Color(0xFF2A2B30), // subtle surfaces/inputs
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F10),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      home: const AuctionsScreen(),
    );
  }
}

/// -------------------- MODELS --------------------

enum AuctionStatus { live, upcoming, ended }

class Auction {
  final String id;
  final String title;
  final String imageUrl;
  final int viewers; // live metric
  final int interested; // upcoming metric
  final DateTime? startsAt; // upcoming
  final DateTime? endsAt; // ended
  final int? firstBid; // ended
  final int? finalBid; // ended
  final int? currentPrice; // live & upcoming
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

/// -------------------- FAKE REPOSITORY --------------------

class AuctionsRepository {
  static const _images = [
    //'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?q=80&w=1600&auto=format&fit=crop',
    //'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1600&auto=format&fit=crop',
    // 'https://images.unsplash.com/photo-1512446816042-444d641267d4?q=80&w=1600&auto=format&fit=crop',
    //  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1600&auto=format&fit=crop',
    // 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1600&auto=format&fit=crop',
  ];

  Future<List<Auction>> fetch({
    required AuctionStatus status,
    required int page,
    int pageSize = 10,
    String query = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 550));

    final now = DateTime.now();
    final base = List.generate(pageSize, (i) {
      final idx = (page - 1) * pageSize + i;
      switch (status) {
        case AuctionStatus.live:
          return Auction(
            id: 'live-$idx',
            title: 'Gaming Console',
            imageUrl: _images[idx % _images.length],
            status: AuctionStatus.live,
            viewers: 25 + (idx % 70),
            currentPrice: 400 + (idx % 6) * 50,
          );
        case AuctionStatus.upcoming:
          return Auction(
            id: 'up-$idx',
            title: 'Gaming Console',
            imageUrl: _images[(idx + 2) % _images.length],
            status: AuctionStatus.upcoming,
            interested: 12 + (idx % 15),
            currentPrice: 1200,
            startsAt: now.add(Duration(days: (idx % 3) + 1, hours: 15)),
          );
        case AuctionStatus.ended:
          return Auction(
            id: 'end-$idx',
            title: 'Gaming Console',
            imageUrl: _images[(idx + 3) % _images.length],
            status: AuctionStatus.ended,
            firstBid: 500,
            finalBid: 1200,
            endsAt: DateTime(now.year, now.month, (now.day - (idx % 10))),
          );
      }
    });

    // Simple "search"
    final filtered = query.isEmpty ? base : base.where((a) =>
        a.title.toLowerCase().contains(query.toLowerCase())).toList();

    return filtered;
  }
}

/// -------------------- SCREEN --------------------

class AuctionsScreen extends StatefulWidget {
  const AuctionsScreen({super.key});

  @override
  State<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends State<AuctionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _queryCtrl = TextEditingController();
  final _repo = AuctionsRepository();
  late final AuctionController controller;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    // Controller initialize
    final tokenStore = TokenStore();
    final apiClient = ApiClient(tokenStore);
    final repository = AuctionRepository(AuctionService(apiClient));
    controller = Get.put(AuctionController(repository));


    controller.loadAuctions();
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
                          content: Text('Hook up your filters here'),
                        ),
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
                  status: AuctionStatus.live,
                  repository: _repo,
                  query: _queryCtrl.text,
                ),
                UpcomingAuctionTile(),
                EndedAuctionView(),/*
                AuctionListView(
                  status: AuctionStatus.ended,
                  repository: _repo,
                  query: _queryCtrl.text,
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- UPDATED PILL TABS --------------------

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
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  labelColor: Colors.black, // selected text
                  unselectedLabelColor: Colors.white, // unselected text
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: ShapeDecoration(
                    color: cs.primary, // orange fill
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
              // subtle separators beneath the indicator
              Positioned(
                left: third,
                top: 6,
                bottom: 6,
                child: Container(width: 1, color: border),
              ),
              Positioned(
                left: third * 2,
                top: 6,
                bottom: 6,
                child: Container(width: 1, color: border),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// -------------------- LIST VIEW (paging + refresh) --------------------

class AuctionListView extends StatefulWidget {
  const AuctionListView({

    super.key,
    required this.status,
    required this.repository,
    this.query = '',
  });

  final AuctionStatus status;
  final AuctionsRepository repository;

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

    final data = await widget.repository.fetch(
      status: widget.status,
      page: _page,
      query: widget.query,
    );

    setState(() {
      _items.addAll(data);
      _page++;
      if (data.isEmpty) _end = true;
      _loading = false;
    });
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
                //return widget.status == AuctionStatus.upcoming
                    //? UpcomingAuctionTile(a: a)
//: EndedAuctionTile(a: a);
              },
            );
          }
        },
      ),
    );
  }
}

/// -------------------- CARDS / TILES --------------------

class LiveAuctionCard extends StatelessWidget {
  const LiveAuctionCard({super.key, required this.a});
  final Auction a;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
      /*  Navigator.of(context).pushReplacement(
         // MaterialPageRoute(builder: (_) => const AuctionDetailScreen()),
        );*/
      },
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
                    child: Image.network(a.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x66000000),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0x55FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, size: 14),
                        const SizedBox(width: 4),
                        Text('${a.viewers}'),
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
                  Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${a.currentPrice}',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ],
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
      onTap: () {
      /*  Navigator.of(context).pushReplacement(
         // MaterialPageRoute(builder: (_) => const AuctionDetailScreen()),
        );*/
      },
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
                child: Image.network(a.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'First Bid: ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '\$${a.firstBid}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Final Bid: ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '\$${a.finalBid}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_clock_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ended ${_friendlyDate(a.endsAt!)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Colors.greenAccent,
                        ),
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

/// -------------------- LOADERS --------------------

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

/// -------------------- UTILS --------------------

String _friendlyDate(DateTime d) {
  final now = DateTime.now();
  final dayDiff = d.difference(now).inDays;
  if (dayDiff >= 1) {
    if (dayDiff == 1) return 'Tomorrow, ${_timeOf(d)}';
    return '${_weekday(d)}, ${_timeOf(d)}';
  } else if (dayDiff == 0) {
    return 'Today, ${_timeOf(d)}';
  } else {
    // past
    final ended = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(d.year, d.month, d.day)).inDays;
    if (ended == 0) return 'today';
    if (ended == 1) return 'yesterday';
    return 'Jun ${d.day}';
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
