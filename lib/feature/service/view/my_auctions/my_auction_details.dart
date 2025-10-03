import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../create_service/provider/auction_provider.dart';

class MyAuctionDetailScreen extends StatefulWidget {
  final String auctionId;
  const MyAuctionDetailScreen({super.key, required this.auctionId});

  @override
  State<MyAuctionDetailScreen> createState() => _MyAuctionDetailScreenState();
}

class _MyAuctionDetailScreenState extends State<MyAuctionDetailScreen> {
  @override
  void initState() {
    super.initState();
    // fetch details
    Future.microtask(
          () => context.read<AuctionProvider>().fetchById(widget.auctionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0F12);
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Consumer<AuctionProvider>(
            builder: (context, p, _) {
              if (p.loadingOne && p.current == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (p.error != null && p.current == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(p.error!, style: const TextStyle(color: Colors.white70)),
                      ),
                      OutlinedButton(
                        onPressed: () => p.fetchById(widget.auctionId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final a = p.current!;
              final title = a.name ?? 'Auction';
              final desc = (a.description ?? '').trim().isEmpty
                  ? 'No description provided.'
                  : a.description!.trim();
              final start = a.startingBid != null ? '\$${_comma(a.startingBid!)}' : '-';
              final schedule = _schedule(a.scheduleDate, a.scheduleTime);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Container(
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
                        // ===== Header image + overlays =====
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.asset(
                                  'assets/images/earpod.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.black26,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                            ),

                            // soft bottom gradient for text legibility
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
                                  _CircleIconButton(
                                    icon: Icons.arrow_back_ios_new,
                                    onTap: () => Get.back(),
                                  ),
                                  const Spacer(),
                                  _CircleIconButton(icon: Icons.share_outlined, onTap: () {}),
                                  const SizedBox(width: 8),
                                  _CircleIconButton(icon: Icons.more_horiz, onTap: () {}),
                                ],
                              ),
                            ),

                            // LIVE pill
                            Positioned(
                              top: 44,
                              left: 58,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(.96),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('LIVE',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ),

                            // author chip + stats
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Eleanor Pena',
                                          style: TextStyle(
                                              color: Colors.white.withOpacity(.95),
                                              fontWeight: FontWeight.w700)),
                                      Text('@eleanorpena',
                                          style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12)),
                                    ],
                                  ),
                                  const Spacer(),
                                  const _TinyPill(icon: Icons.remove_red_eye_outlined, text: '142'),
                                  const SizedBox(width: 6),
                                  const _TinyPill(icon: Icons.favorite_border, text: '86'),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ===== Body =====
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title + timer
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const _TimerPill(text: 'Ends in: 2:57'),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // description
                              Text(
                                desc,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.75),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // current bid
                              Row(
                                children: [
                                  Text(
                                    'Current Bid ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.85),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    start,
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
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
                          child: Row(
                            children: [
                              _InfoPill(icon: Icons.event, text: schedule),
                              const SizedBox(width: 12),
                              _InfoPill(icon: Icons.schedule, text: _duration(a.duration)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: border),

                        // section header
                        const _SectionHeaderWithIcon(
                          icon: Icons.chat_bubble_outline,
                          text: 'Live Chat',
                        ),

                        // your chat list (kept minimal so you can drop-in your items)
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
              );
            },
          ),
        ),
      ),
    );
  }

  // ===== helpers =====
  static String _comma(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      b.write(s[i]);
      final left = s.length - i - 1;
      if (left % 3 == 0 && left != 0) b.write(',');
    }
    return b.toString();
  }

  static String _schedule(String? d, String? t) {
    final dd = (d ?? '').trim(), tt = (t ?? '').trim();
    if (dd.isEmpty && tt.isEmpty) return '-';
    return '$dd ${tt.isEmpty ? '' : tt}';
  }

  static String _duration(int? m) {
    if (m == null) return '-';
    if (m >= 60) {
      final h = m ~/ 60;
      return '$h hour${h > 1 ? 's' : ''}';
    }
    return '$m minutes';
  }
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
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12),
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
