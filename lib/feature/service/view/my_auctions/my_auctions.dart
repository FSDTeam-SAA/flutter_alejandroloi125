// lib/feature/auction/view/my_auction_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/api_paths.dart';
import '../../../../core/env/env.dart';
import '../../../../core/network/api_service/api_client.dart';
import '../../../auth/providers/auth_provider.dart';
import 'my_auction_details.dart';

class MyAuctionScreen extends StatefulWidget {
  const MyAuctionScreen({super.key});
  @override
  State<MyAuctionScreen> createState() => _MyAuctionScreenState();
}

class _MyAuctionScreenState extends State<MyAuctionScreen> {
  late final Dio _dio;

  final _scroll = ScrollController();

  // state
  bool _loading = true;
  bool _paging = false;
  String? _error;

  int _page = 1;
  int _totalPages = 1; // will be inferred from API if available
  final int _limit = 10;

  final List<_Auction> _items = [];

  @override
  void initState() {
    super.initState();
    _dio = context.read<ApiClient>().dio;

    // initial load
    _fetch(page: 1, limit: _limit);

    // infinite scroll
    _scroll.addListener(() {
      if (_paging || _loading) return;
      final nearBottom =
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120;
      if (nearBottom && _page < _totalPages) {
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

  Future<void> _fetch({required int page, required int limit}) async {
    try {
      if (page == 1) setState(() => _loading = true);

      final userId = context.read<AuthProvider>().user?.id;

      final q = <String, dynamic>{
        if (userId != null && userId.isNotEmpty) 'userid': userId,
        'page': page,
        'limit': limit,
      };

      final res = await _dio.get(
        ApiPaths.allAuction,
        queryParameters: q,
      );

      final list = _pickList(
        res.data,
        keys: const ['auctions', 'data', 'items', 'results'],
      );

      _totalPages =
          _inferTotalPages(res.data, fallback: (_page == 1) ? 1 : _totalPages);

      final parsed = <_Auction>[];
      if (list != null) {
        for (final raw in list) {
          final m = Map<String, dynamic>.from(raw as Map);
          final sched =
          (m['schedule'] is Map) ? Map<String, dynamic>.from(m['schedule']) : null;

          parsed.add(
            _Auction(
              id: (m['id'] ?? m['_id'] ?? '').toString(),
              name: _text(m['name'] ?? m['title'] ?? 'Auction'),
              startingBid:
              _asInt(m['startingBid'] ?? m['starting_price'] ?? m['price'] ?? 0),
              fundingDuration: _text(m['fundingDuration'] ?? m['duration'] ?? ''),
              scheduleDate: _text(sched?['date'] ?? m['date'] ?? ''),
              scheduleTime: _text(sched?['time'] ?? m['time'] ?? ''),
              cover: _absolute(
                  _resolveImage(m['image'] ?? m['cover'] ?? m['thumbnail'])),
              status: _text(m['status'] ?? ''),
              isCompleted: _text(m['status'] ?? '').toLowerCase().contains('complete'),
            ),
          );
        }
      }

      setState(() {
        if (page == 1) _items.clear();
        _items.addAll(parsed);
        _page = page;
        _loading = false;
        _error = null;
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

  // ---------- helpers: parsing ----------
  static List? _pickList(dynamic root, {required List<String> keys}) {
    if (root is List) return root;
    if (root is! Map) return null;

    final data = root['data'];
    if (data is List) return data;
    if (data is Map) {
      for (final k in keys) {
        final v = data[k];
        if (v is List) return v;
      }
    }

    for (final v in root.values) {
      if (v is List) return v;
      if (v is Map) {
        for (final vv in v.values) {
          if (vv is List) return vv;
        }
      }
    }
    return null;
  }

  static int _inferTotalPages(dynamic root, {required int fallback}) {
    try {
      if (root is Map) {
        final meta = root['meta'] ?? root['pagination'] ?? root['page'];
        if (meta is Map) {
          final totalPages = meta['totalPages'] ?? meta['pages'] ?? meta['total_pages'];
          if (totalPages is num) return totalPages.toInt();
          final total = meta['total'] ?? meta['count'];
          final limit = meta['limit'] ?? meta['perPage'] ?? meta['per_page'];
          if (total is num && limit is num && limit > 0) {
            return ((total / limit).ceil()).clamp(1, 9999);
          }
        }
      }
    } catch (_) {}
    return fallback;
  }

  static String _text(dynamic v) => (v == null) ? '' : v.toString();

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static String _resolveImage(dynamic raw) {
    const fallback = 'assets/images/watch.jpg';
    if (raw == null) return fallback;
    if (raw is List && raw.isNotEmpty) return _resolveImage(raw.first);
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
      return s;
    }
    return fallback;
  }

  static String _absolute(String url) {
    final u = url.trim();
    if (u.isEmpty) return u;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppEnv.baseUrl;
    if (base.isEmpty) return u;
    if (base.endsWith('/') && u.startsWith('/')) return '$base${u.substring(1)}';
    if (!base.endsWith('/') && !u.startsWith('/')) return '$base/$u';
    return '$base$u';
  }

  Future<void> _delete(String id) async {
    setState(() => _items.removeWhere((a) => a.id == id));
    Get.snackbar('Deleted', 'Auction removed', snackPosition: SnackPosition.TOP);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      // REMOVED the local AppBar to avoid the extra dark header area.
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (_loading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if ((_error ?? '').isNotEmpty && items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child:
                  Text(_error!, style: const TextStyle(color: Colors.white70)),
                ),
              );
            }
            if (items.isEmpty) {
              return const Center(
                child:
                Text('No auctions found', style: TextStyle(color: Colors.white70)),
              );
            }

            return ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: items.length + (_page < _totalPages ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                if (i >= items.length) {
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
                final price =
                (a.startingBid == null) ? '-' : '\$${_comma(a.startingBid!)}';
                final time =
                _timeLabel(a.scheduleDate, a.scheduleTime, a.fundingDuration);

                final statusLower = a.status.toLowerCase();
                final isCompleted =
                    a.isCompleted || statusLower.contains('complete');
                final inProgress =
                    statusLower.contains('progress') || statusLower.contains('live');

                final statusText = isCompleted
                    ? 'Completed'
                    : inProgress
                    ? 'In Progress'
                    : (a.status.isEmpty ? 'In Progress' : a.status);

                final statusColor =
                isCompleted ? const Color(0xFF5CD7B0) : const Color(0xFFFF8A34);

                return _AuctionCard.dynamic(
                  imageUrl: a.cover ?? 'assets/images/watch.jpg',
                  title: a.name,
                  priceLabel: price,
                  timeLabel: time,
                  status: statusText,
                  statusColor: statusColor,
                  completed: isCompleted,
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
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
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
          },
        ),
      ),
    );
  }
}

// ==== data model used by the screen ====
class _Auction {
  final String id;
  final String name;
  final int? startingBid;
  final String fundingDuration;
  final String? scheduleDate;
  final String? scheduleTime;
  final String? cover;
  final String status;
  final bool isCompleted;

  _Auction({
    required this.id,
    required this.name,
    required this.startingBid,
    required this.fundingDuration,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.cover,
    required this.status,
    required this.isCompleted,
  });
}

// ==== formatting + small helpers ====
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

// ================= Card UI =================
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
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _broken(),
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0x11000000),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
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
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
    child:
    const Icon(Icons.broken_image_outlined, color: Colors.white70),
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
      child: Row(children: [
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
      ]),
    );
  }
}
