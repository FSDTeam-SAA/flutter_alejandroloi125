import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/language/language_controller.dart';
import '../../../providers/auction_provider.dart';
import '../../models/auction.dart' as api;
import '../../app_ground.dart';
import '../../../core/env/env.dart' show AppEnv;

class AuctionDetailScreen extends StatelessWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F0F10),
      cardColor: const Color(0xFF1A1B1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF8C3B),
        secondary: Color(0xFF2A2B30),
        surface: Color(0xFF1A1B1E),
      ),
      dividerColor: const Color(0xFF2B2C31),
    );

    return Theme(
      data: dark,
      child: AuctionDetailPage(auctionId: auctionId),
    );
  }
}

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;
  const AuctionDetailPage({super.key, required this.auctionId});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

// ---------- status helper ----------
enum _AStatus { live, upcoming, ended }

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  final bidCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

  api.AuctionDto? _dto;
  bool _loading = true;
  String? _error;

  bool _placingBid = false;
  bool _sendingMsg = false;

  late DateTime _endTime;
  late Stream<String> _timer$;

  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    bidCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      api.AuctionDto? dto;

      // Prefer fetching by ID
      if (widget.auctionId.isNotEmpty) {
        dto = await context.read<AuctionProvider>().one(widget.auctionId);
      } else if (Get.arguments is Map) {
        // If navigated with Get.arguments, adapt that shape to our DTO
        final a = Map<String, dynamic>.from(Get.arguments as Map);
        dto = api.AuctionDto(
          id: (a['auctionId'] ?? a['id'] ?? '').toString(),
          name: (a['name'] ?? '').toString(),
          description: (a['description'] ?? '').toString(),
          category: const [],
          startingBid:
              int.tryParse('${a['startingBid'] ?? a['price'] ?? 0}') ?? 0,
          image: [
            api.AuctionImageDto(
              url: (a['image'] ?? '').toString(),
              filename: '',
              publicId: '',
            ),
          ],
          duration: int.tryParse('${a['duration'] ?? 60}'),
          schedule: api.AuctionScheduleDto.fromJson(
            Map<String, dynamic>.from((a['schedule'] as Map?) ?? const {}),
          ),
          skills: const [],
          createdBy: null,
          location: (a['location'] ?? '').toString(),
        );
      }

      if (dto == null) throw StateError('Auction not found');

      // set up countdown + preload bid field
      _setupTimer(dto);
      bidCtrl.text = dto.startingBid.toString();

      // Pull chat/bid thread
      final chat = await context.read<AuctionProvider>().getChat(dto.id);
      _messages
        ..clear()
        ..addAll(
          chat.map(
            (e) => _ChatMessage(
              name: 'User',
              avatar:
                  'https://i.pravatar.cc/100?img=${(e.id.hashCode % 70).abs()}',
              timeAgo: _timeAgo(e.createdAt),
              text: (e.message?.isNotEmpty ?? false)
                  ? e.message!
                  : (e.amount != null ? '\$${e.amount}' : ''),
            ),
          ),
        );

      if (!mounted) return;
      setState(() {
        _dto = dto;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _setupTimer(api.AuctionDto dto) {
    final start = _parseDateTime(dto.schedule.date, dto.schedule.time);
    final durationMin = dto.duration ?? 60;
    _endTime = (start ?? DateTime.now()).add(Duration(minutes: durationMin));

    _timer$ = Stream.periodic(const Duration(seconds: 1), (_) {
      final diff = _endTime.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final m = diff.inMinutes.remainder(60).toString();
      final s = (diff.inSeconds.remainder(60)).toString().padLeft(2, '0');
      return '$m:$s';
    });
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

  // Determine status from schedule/duration
  _AStatus _statusOf(api.AuctionDto d) {
    final start = _parseDateTime(d.schedule.date, d.schedule.time);
    final durMin = d.duration ?? 60;
    if (start == null) return _AStatus.live;
    final end = start.add(Duration(minutes: durMin));
    final now = DateTime.now();
    if (now.isBefore(start)) return _AStatus.upcoming;
    if (now.isAfter(end)) return _AStatus.ended;
    return _AStatus.live;
  }

  // --- inside _AuctionDetailPageState ---

  Future<void> _placeBid() async {
    FocusScope.of(context).unfocus();
    final raw = bidCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(raw) ?? 0;
    if (amount <= 0) {
      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Invalid bid',
        'Please enter a number greater than 0',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _placingBid = true);
    try {
      await context.read<AuctionProvider>().bidOrMessage(
        auctionId: _dto!.id,
        amount: amount, // <— amount only
      );

      // optimistic UI
      setState(() {
        _messages.insert(
          0,
          _ChatMessage(
            name: 'You',
            avatar: 'https://i.pravatar.cc/100?img=1',
            timeAgo: 'now',
            text: '\$$amount',
          ),
        );
      });

      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Success',
        'Bid placed successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
          backgroundColor: Colors.white,
          colorText: Colors.black,
          'Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _placingBid = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Empty message',
        'Type something to send',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _sendingMsg = true);
    try {
      await context.read<AuctionProvider>().bidOrMessage(
        auctionId: _dto!.id,
        message: text, // <— message only
      );

      setState(() {
        _messages.insert(
          0,
          _ChatMessage(
            name: 'You',
            avatar: 'https://i.pravatar.cc/100?img=1',
            timeAgo: 'now',
            text: text,
          ),
        );
      });
      msgCtrl.clear();

      Get.snackbar(
        backgroundColor: Colors.white,
          colorText: Colors.black,
          'Success', 'Message sent', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar(
          backgroundColor: Colors.white,
          colorText: Colors.black,

          'Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _sendingMsg = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final dto = _dto!;
    final isLive = _statusOf(dto) == _AStatus.live;
    final title = dto.name;
    final description = dto.description.isEmpty ? '—' : dto.description;
    final imageUrl = _absolute(dto.image.isNotEmpty ? dto.image.first.url : '');
    final currentBid = dto.startingBid; // replace when you have live current bid
    final langController = Get.put(LanguageController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
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
        title: Text(langController.t('auctions_details'),style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ===== Header image =====
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl.isEmpty
                        ? 'https://via.placeholder.com/1600x900.png?text=Auction' : imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x33000000),
                          Color(0x99000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        const Spacer(),
                        const SizedBox(width: 10),
                        _circleBtn(
                          icon: Icons.favorite_border_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  if (isLive)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 10, color: Colors.white),
                            SizedBox(width: 6),
                            // Text(
                            //   'LIVE',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w800,
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=12',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Eleanor Pena',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '@eleanorpena',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _metricChip(Icons.visibility, '142'),
                        const SizedBox(width: 6),
                        _metricChip(Icons.favorite, '86'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Body =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      StreamBuilder<String>(
                        stream: _timer$,
                        initialData: '3:00',
                        builder: (_, snap) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A2A23),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFF8C3B),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Ends in: ${snap.data}',
                            style: const TextStyle(
                              color: Color(0xFFFF8C3B),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 16),

                  // Current bid + place bid
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Bid',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$$currentBid',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: bidCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: Theme.of(context).colorScheme.secondary,
                            hintText: 'e.g. 1250',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _placingBid ? null : _placeBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _placingBid
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            :  Text(langController.t('bid'), style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Live Chat header
                  Row(
                    children:  [
                      Icon(Icons.chat_bubble_outline_rounded),
                      SizedBox(width: 8),
                      Text(langController.t('live_chat'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Chat list
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final m = _messages[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(m.avatar),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          m.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        m.timeAgo,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.text,
                                    style: const TextStyle(height: 1.25),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom message bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: msgCtrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: '${langController.t('type_message')}...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                width: 56,
                child: ElevatedButton(
                  onPressed: _sendingMsg ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: _sendingMsg
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _absolute(String url) {
    final u = url.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = AppEnv.baseUrl;
    if (base.isEmpty) return u;
    if (base.endsWith('/') && u.startsWith('/'))
      return '$base${u.substring(1)}';
    if (!base.endsWith('/') && !u.startsWith('/')) return '$base/$u';
    return '$base$u';
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ChatMessage {
  final String name;
  final String avatar;
  final String timeAgo;
  final String text;
  _ChatMessage({
    required this.name,
    required this.avatar,
    required this.timeAgo,
    required this.text,
  });
}

/// ===== helpers =====
Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x40000000),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Icon(icon, size: 20),
    ),
  );
}

Widget _metricChip(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x33000000),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x55FFFFFF)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
