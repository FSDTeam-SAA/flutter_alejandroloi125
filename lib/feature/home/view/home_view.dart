// lib/feature/home/view/home_screen_view.dart
import 'package:alejandroloi/core/common/widgets/live_action_card.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/feature/home/widgets/botton_card.dart';
import 'package:alejandroloi/feature/home/widgets/investdesk_card.dart';
import 'package:alejandroloi/feature/home/widgets/project_card.dart';
import 'package:alejandroloi/feature/investments/view/investment_screen.dart';
import 'package:alejandroloi/feature/investments/widgets/progrees.dart';
import 'package:alejandroloi/feature/auctions/view/auction_screen.dart';
import 'package:alejandroloi/feature/project/view/project.dart';

import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';
import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});
  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  late final Dio _dio;

  bool _loading = true;
  String? _error;

  // Greeting fallbacks (match your mock)
  String _helloName = 'Abu Sayed';
  String _helloLocation = 'NY,USA';
  String? _avatarUrl; // NEW: dynamic avatar

  // Lists for sections
  final List<Auctions> _auctions = [];
  final List<_InvestItem> _invests = [];
  final List<_ProjectMini> _projects = [];

  @override
  void initState() {
    super.initState();
    _dio = context.read<ApiClient>().dio;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ---------- 1) Header (name/address/avatar) ----------
      try {
        // Use what we already have first
        final me = context.read<AuthProvider>().user;
        if (me != null) {
          if ((me.name ?? '').trim().isNotEmpty) _helloName = me.name!.trim();
          if ((me.address ?? '').trim().isNotEmpty) {
            _helloLocation = me.address!.trim();
          }
          _avatarUrl = me.imageUrl ?? me.avatarUrl ?? me.avatar ?? _avatarUrl;
        }

        // Then confirm with server
        final userId = me?.id ?? context.read<AuthProvider>().user?.id;
        if (userId != null && userId.isNotEmpty) {
          final rUser = await _dio.get(ApiPaths.userGetOne(userId));
          final map = (rUser.data is Map) ? rUser.data as Map : {};
          final data = map['data'];
          if (data is Map) {
            final name = _textize(data['name']).trim();
            if (name.isNotEmpty) _helloName = name;

            // Prefer "address", otherwise try "location" or "nationality"
            final addrRaw = data['address'] ?? data['location'] ?? data['nationality'];
            final addr = _textize(addrRaw).trim();
            if (addr.isNotEmpty) _helloLocation = addr;

            // avatar: could be string or { url: "..."}
            final a = data['avatar'];
            String? url;
            if (a is String && a.trim().isNotEmpty) {
              url = a.trim();
            } else if (a is Map && a['url'] != null) {
              url = a['url'].toString();
            }
            if (url != null && url.isNotEmpty) _avatarUrl = url;
          }
        }
      } catch (_) {
        // ignore header failures, keep fallbacks
      }

      // ---------- 2) Lists in parallel ----------
      final res = await Future.wait([
        _dio.get(ApiPaths.allAuction),     // /auction/all-auction
        _dio.get(ApiPaths.allInvestment),  // /investment/all-investment
        _dio.get(ApiPaths.allProject),     // /project/all-project
      ]);

      // ---------- Auctions ----------
      _auctions.clear();
      final auctionsList =
      _pickList(res[0].data, keys: const ['auctions', 'data', 'items', 'results']);
      if (auctionsList != null) {
        for (final raw in auctionsList) {
          final m = Map<String, dynamic>.from(raw as Map);
          _auctions.add(Auctions(
            imageUrl: _textize(m['image'] ?? m['cover'] ?? 'assets/images/tree.jpg'),
            title: _textize(m['title'] ?? m['name'] ?? 'Live Auction'),
            currentPrice: _asDouble(m['currentPrice'] ?? m['price'] ?? m['amount'] ?? 0),
            viewers: _asInt(m['viewers'] ?? m['watchers'] ?? 0),
          ));
        }
      }

      // ---------- Invest Desk ----------
      _invests.clear();
      final investsList = _pickList(
        res[1].data,
        keys: const ['invests', 'investments', 'data', 'items', 'results'],
      );
      if (investsList != null) {
        for (final raw in investsList.take(5)) {
          final m = Map<String, dynamic>.from(raw as Map);
          _invests.add(_InvestItem(
            type: _textize(m['category'] ?? m['type'] ?? 'Agriculture'),
            title: _textize(m['name'] ?? m['title'] ?? 'Urban Farming Initiative'),
            percent: _asInt(m['progressPct'] ?? m['fundedPercent'] ?? 0),
            price: _asNum(m['target'] ?? m['amount'] ?? m['price'] ?? 0).toString(),
            assetImage: 'assets/images/tree.jpg', // keep your mock look
          ));
        }
      }

      // ---------- Projects ----------
      _projects.clear();
      final projectsList =
      _pickList(res[2].data, keys: const ['projects', 'data', 'items', 'results']);
      if (projectsList != null) {
        for (final raw in projectsList.take(5)) {
          final m = Map<String, dynamic>.from(raw as Map);
          _projects.add(_ProjectMini(
            category: _textize(m['category'] ?? 'Design'),
            title: _textize(m['title'] ?? m['name'] ?? 'Project'),
            blurb: _textize(m['description'] ?? 'Looking for an experienced pro to help…'),
            priceRange: _priceRange(m),
            duration: (m['duration']?.toString().isNotEmpty == true)
                ? '${m['duration']} Days'
                : '15 Days',
            location: _textize(m['location'] ?? 'Brooklyn, NY'),
            proposals: (m['proposalsCount'] != null)
                ? '${m['proposalsCount']} Proposals'
                : '8 Proposals',
            avatars: const [
              'https://i.pravatar.cc/60?img=12',
              'https://i.pravatar.cc/60?img=22',
              'https://i.pravatar.cc/60?img=32',
              'https://i.pravatar.cc/60?img=42',
            ],
          ));
        }
      }

      setState(() => _loading = false);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = (d is Map && d['message'] is String)
          ? d['message'] as String
          : (e.message ?? 'Request failed');
      setState(() {
        _error = msg;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ---------------- helpers ----------------
  /// Accepts shapes like:
  /// {data:[...]}, {data:{projects:[...]}}, {data:{results:[...]}} etc.
  static List? _pickList(dynamic root, {required List<String> keys}) {
    if (root is! Map) return null;
    final data = root['data'];
    if (data is List) return data;
    if (data is Map) {
      for (final k in keys) {
        final v = data[k];
        if (v is List) return v;
      }
    }
    return null;
  }

  static String _textize(dynamic v) {
    if (v == null) return '';
    if (v is List) return v.join(', '); // removes [brackets] in UI
    return v.toString();
  }

  static double _asDouble(dynamic v) =>
      (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
  static int _asInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
  static num _asNum(dynamic v) => (v is num) ? v : num.tryParse('$v') ?? 0;

  static String _priceRange(Map<String, dynamic> m) {
    final low = _asNum(m['budgetMin'] ?? m['min'] ?? 1500);
    final high = _asNum(m['budgetMax'] ?? m['max'] ?? 3000);
    return '\$ ${low.toStringAsFixed(0)} - ${high.toStringAsFixed(0)}';
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            children: [
              // Dynamic avatar with graceful fallback
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade700,
                backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? NetworkImage(_avatarUrl!) as ImageProvider
                    : null,
                child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                    ? const Icon(Icons.account_circle_outlined,
                    color: Colors.white, size: 38)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $_helloName ",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _helloLocation,
                      style:
                      const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_on_outlined,
                    color: Colors.white, size: 30),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.black,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BottomCard(
                imagePath: Images.currency,
                title: "Investments",
                subtitle:
                "Develop Investment Strategy and Engage with Potential Funders.",
                onTap: () {
                  Get.to(() => const InvestmentsScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300));
                },
              ),
              const SizedBox(height: 15),
              BottomCard(
                imagePath: Images.layout,
                title: "Project",
                subtitle:
                "Post a need or offer to complete someone else's project",
                onTap: () {
                  Get.to(() => const ProjectScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300));
                },
              ),
              const SizedBox(height: 15),
              BottomCard(
                imagePath: Images.key,
                title: "Auctions",
                subtitle:
                "Participate in the live product auction by placing your bid.",
                onTap: () {
                  Get.to(() => const AuctionScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300));
                },
              ),

              const SizedBox(height: 20),

              // -------- Live Auctions --------
              const SectionHeader(title: 'Live Auctions'),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _auctions.isNotEmpty ? _auctions.length : 10,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (_, index) {
                    final a = _auctions.isNotEmpty
                        ? _auctions[index]
                        : Auctions(
                      imageUrl: "assets/images/tree.jpg",
                      title: "Gaming Console",
                      currentPrice: 450,
                      viewers: 25,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 160,
                        child: LiveAuctionCards(auction: a, onTap: () {}),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // -------- Invest Desk --------
              const SectionHeader(title: 'Invest Desk'),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _invests.isNotEmpty ? _invests.length : 3,
                  itemBuilder: (_, index) {
                    final it = _invests.isNotEmpty
                        ? _invests[index]
                        : _InvestItem(
                      type: 'Agriculture',
                      title: 'Urban Farming Initiative',
                      percent: 45,
                      price: '25000',
                      assetImage: 'assets/images/tree.jpg',
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () => Get.to(const InvestmentsScreen()),
                        child: InvestDeskCard(
                          type: it.type,
                          imagePath: it.assetImage,
                          title: it.title,
                          progressBar: ProgressBar(
                            value: it.percent.toDouble(),
                            color: AppColors.bottomColor1,
                          ),
                          price: it.price,
                          percent: it.percent.toString(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // -------- Project Proposal --------
              const SectionHeader(title: 'Project Proposal'),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _projects.isNotEmpty ? _projects.length : 2,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (_, index) {
                    final p = _projects.isNotEmpty
                        ? _projects[index]
                        : _ProjectMini(
                      category: 'Design',
                      title: 'Website Redesign for Local Business',
                      blurb:
                      'Looking for an experienced web designer to revamp our company website. Need',
                      priceRange: '\$ 1,500 - 3,000',
                      duration: '15 Days',
                      location: 'Brooklyn, NY',
                      proposals: '8 Proposals',
                      avatars: const [
                        'https://i.pravatar.cc/60?img=12',
                        'https://i.pravatar.cc/60?img=22',
                        'https://i.pravatar.cc/60?img=32',
                        'https://i.pravatar.cc/60?img=42',
                      ],
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ProjectMiniCard(
                        category: p.category,
                        title: p.title,
                        blurb: p.blurb,
                        priceRange: p.priceRange,
                        duration: p.duration,
                        location: p.location,
                        proposals: p.proposals,
                        avatars: p.avatars,
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),

              if (_loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Colors.white),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Small header row for "See all" style sections (kept simple)
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(
              color: Color(0xFFFF8C3B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- local mapping models ----------
class _InvestItem {
  final String type;
  final String title;
  final int percent;
  final String price;
  final String assetImage;
  _InvestItem({
    required this.type,
    required this.title,
    required this.percent,
    required this.price,
    required this.assetImage,
  });
}

class _ProjectMini {
  final String category;
  final String title;
  final String blurb;
  final String priceRange;
  final String duration;
  final String location;
  final String proposals;
  final List<String> avatars;
  _ProjectMini({
    required this.category,
    required this.title,
    required this.blurb,
    required this.priceRange,
    required this.duration,
    required this.location,
    required this.proposals,
    required this.avatars,
  });
}
