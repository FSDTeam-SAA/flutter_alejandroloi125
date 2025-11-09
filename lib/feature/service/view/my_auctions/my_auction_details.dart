// lib/feature/auction/view/my_auction_details.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/api_paths.dart';
import '../../../../core/env/env.dart';
import '../../../../core/language/language_controller.dart';
import '../../../../core/network/api_service/api_client.dart';
import '../../../app_ground.dart';

class MyAuctionDetailScreen extends StatefulWidget {
  final String auctionId;

  const MyAuctionDetailScreen({super.key, required this.auctionId});

  @override
  State<MyAuctionDetailScreen> createState() => _MyAuctionDetailScreenState();
}

class _MyAuctionDetailScreenState extends State<MyAuctionDetailScreen> {
  late final Dio _dio;

  bool _loading = true;
  String? _error;

  // ---- data from API ----
  String _title = '';
  String _desc = '';
  String _image = ''; // absolute url or asset fallback
  String _currentBid = '';
  String _scheduleText = '';
  String _durationText = '';

  @override
  void initState() {
    super.initState();
    _dio = context.read<ApiClient>().dio;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get(ApiPaths.getAuctionById(widget.auctionId));

      final data = _pickMap(res.data, keys: const ['data', 'auction']);
      if (data == null) throw Exception('Auction not found');

      final sched = (data['schedule'] is Map)
          ? Map<String, dynamic>.from(data['schedule'])
          : const <String, dynamic>{};

      final imageRaw = data['image'] ?? data['cover'] ?? data['thumbnail'];
      final img = _absolute(_resolveImage(imageRaw));

      setState(() {
        _title = (data['name'] ?? data['title'] ?? 'Auction').toString();
        _desc = (data['description'] ?? '').toString();
        _image = img.isEmpty ? 'assets/images/earpod.jpg' : img;

        final bidNum =
            data['currentBid'] ??
            data['starting_bid'] ??
            data['startingBid'] ??
            data['price'];
        _currentBid = _formatMoney(bidNum);

        final date = (sched['date'] ?? data['date'] ?? '').toString();
        final time = (sched['time'] ?? data['time'] ?? '').toString();
        _scheduleText = [
          date,
          time,
        ].where((s) => s.trim().isNotEmpty).join(' ');
        if (_scheduleText.isEmpty) _scheduleText = '—';

        final dur = data['duration']?.toString() ?? '';
        _durationText = dur.isEmpty ? '—' : '$dur minutes';

        _loading = false;
      });
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

  static Map<String, dynamic>? _pickMap(
    dynamic root, {
    required List<String> keys,
  }) {
    if (root is Map) {
      if (root['data'] is Map) return Map<String, dynamic>.from(root['data']);
      for (final k in keys) {
        if (root[k] is Map) return Map<String, dynamic>.from(root[k]);
      }
    }
    return null;
  }

  static String _formatMoney(dynamic n) {
    final v = (n is num) ? n : num.tryParse('$n');
    if (v == null) return '\$0';
    final s = v.toInt().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      b.write(s[i]);
      final left = s.length - i - 1;
      if (left % 3 == 0 && left != 0) b.write(',');
    }
    return '\$${b.toString()}';
  }

  static String _resolveImage(dynamic raw) {
    const fallback = 'assets/images/earpod.jpg';
    if (raw == null) return fallback;

    if (raw is List && raw.isNotEmpty) {
      return _resolveImage(raw.first);
    }

    if (raw is Map) {
      final u = raw['url'] ?? raw['secure_url'] ?? raw['src'] ?? raw['path'];
      if (u is String && u.trim().isNotEmpty) return u.trim();
      return fallback;
    }

    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return fallback;
      if (s.startsWith('http://') || s.startsWith('https://')) return s;
      if (s.startsWith('assets/')) return s;
      final m = RegExp(r'(https?://[^\s,}]+)').firstMatch(s);
      if (m != null) return m.group(0)!;
      return s; // relative path
    }

    return fallback;
  }

  static String _absolute(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppEnv.baseUrl;
    if (base.isEmpty) return u;
    if (base.endsWith('/') && u.startsWith('/'))
      return '$base${u.substring(1)}';
    if (!base.endsWith('/') && !u.startsWith('/')) return '$base/$u';
    return '$base$u';
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0F12);
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);
    final langController = Get.put(LanguageController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.offAll(() => const AppGround());
              }
            },
          ),
          title: Text(
            langController.t('auctions_details'),
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
          centerTitle: false,
        ),
        backgroundColor: bg,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== Header image + overlays =====
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: _image.startsWith('http')
                                            ? Image.network(
                                                _image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _broken(),
                                                loadingBuilder:
                                                    (ctx, child, progress) {
                                                      if (progress == null) {
                                                        return child;
                                                      }
                                                      return Container(
                                                        color: const Color(
                                                          0x11000000,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const SizedBox(
                                                          height: 22,
                                                          width: 22,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Image.asset(
                                                _image.isEmpty
                                                    ? 'assets/images/earpod.jpg'
                                                    : _image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _broken(),
                                              ),
                                      ),
                                    ),

                                    // soft bottom gradient
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(14),
                                                ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.08),
                                                Colors.black.withOpacity(0.26),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // top actions
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: Row(
                                        children: [
                                          const Spacer(),
                                          _CircleIconButton(
                                            icon: Icons.share_outlined,
                                            onTap: () {},
                                          ),
                                          const SizedBox(width: 8),
                                          _CircleIconButton(
                                            icon: Icons.more_horiz,
                                            onTap: () {},
                                          ),
                                        ],
                                      ),
                                    ),

                                    // LIVE pill
                                    Positioned(
                                      top: 44,
                                      left: 58,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(.96),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black45,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.fiber_manual_record,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'LIVE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // author chip + stats (placeholder)
                                    Positioned(
                                      left: 12,
                                      bottom: 10,
                                      right: 12,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(
                                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Eleanor Pena',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.95),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                '@eleanorpena',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          const _TinyPill(
                                            icon: Icons.remove_red_eye_outlined,
                                            text: '142',
                                          ),
                                          const SizedBox(width: 6),
                                          const _TinyPill(
                                            icon: Icons.favorite_border,
                                            text: '86',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // ===== Body =====
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    14,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const _TimerPill(text: 'Ends soon'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _desc.isEmpty ? '—' : _desc,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.75),
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            'Current Bid ',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                .85,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _currentBid.isEmpty
                                                ? '\$0'
                                                : _currentBid,
                                            style: const TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1, color: border),

                                // schedule + duration
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    14,
                                    2,
                                  ),
                                  child: Row(
                                    children: [
                                      _InfoPill(
                                        icon: Icons.event,
                                        text: _scheduleText,
                                      ),
                                      const SizedBox(width: 12),
                                      _InfoPill(
                                        icon: Icons.schedule,
                                        text: _durationText,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),
                                const Divider(height: 1, color: border),

                                _SectionHeaderWithIcon(
                                  icon: Icons.chat_bubble_outline,
                                  text: langController.t('live_chat'),
                                ),

                                // demo chat list
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
                                  child: Column(
                                    children: [
                                      _ChatItem(
                                        avatar:
                                            'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91',
                                        name: 'Ronald Richards',
                                        timeAgo: '2m ago',
                                        message: '\$500',
                                      ),
                                      _ChatItem(
                                        avatar:
                                            'https://images.unsplash.com/photo-1527980965255-d3b416303d12',
                                        name: 'Arlene McCoy',
                                        timeAgo: '2m ago',
                                        message: '\$800',
                                      ),
                                      _ChatItem(
                                        avatar:
                                            'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c',
                                        name: 'Darrell Steward',
                                        timeAgo: '2m ago',
                                        message: "What's the band material?",
                                      ),
                                      _ChatItem(
                                        avatar:
                                            'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
                                        name: 'Kathryn Murphy',
                                        timeAgo: '2m ago',
                                        message: '\$1000',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
        ),
      ),
    );
  }

  Widget _broken() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined),
  );
}

// ===== atoms & small widgets =====
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TinyPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  final String text;
  const _TimerPill({required this.text});
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF8A34);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(.7)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: accent,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeaderWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionHeaderWithIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF242931);
    return Column(
      children: [
        const Divider(height: 1, color: border),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white.withOpacity(.9)),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: border),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 38,
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
                text,
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
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String avatar;
  final String name;
  final String timeAgo;
  final String message;
  const _ChatItem({
    required this.avatar,
    required this.name,
    required this.timeAgo,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatar)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
