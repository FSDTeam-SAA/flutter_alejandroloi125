import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAuctionDetailScreen extends StatelessWidget {
  const MyAuctionDetailScreen({super.key});

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              // main card
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
                    // header image with actions & live badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              'assets/images/earpod.jpg', // replace with your asset
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.black26,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            children: [
                              _CircleIconButton(
                                icon: Icons.arrow_back_ios_new,
                                onTap: () => Navigator.pop(context),
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
                              color: Colors.red.withOpacity(.92),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                                SizedBox(width: 6),
                                Text('LIVE',
                                    style: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.w800)),
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
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(.7), fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              _TinyPill(icon: Icons.remove_red_eye_outlined, text: '142'),
                              const SizedBox(width: 6),
                              _TinyPill(icon: Icons.favorite_border, text: '86'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title and timer
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Gaming Console',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _TimerPill(text: 'Ends in: 2:57'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.75),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('Current Bid ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.85),
                                      fontWeight: FontWeight.w600)),
                              const Text(
                                '\$1,200',
                                style: TextStyle(
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

                    // live chat header
                    const _SectionHeaderWithIcon(
                      icon: Icons.chat_bubble_outline,
                      text: 'Live Chat',
                    ),

                    // chat list
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        children: const [
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
                          _ChatItem(
                            avatar:
                            'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
                            name: 'Devon Lane',
                            timeAgo: '2m ago',
                            message: 'Beautiful !',
                          ),
                          _ChatItem(
                            avatar:
                            'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91',
                            name: 'Robert Fox',
                            timeAgo: '2m ago',
                            message: "I'll go \$1,200",
                          ),
                          _ChatItem(
                            avatar:
                            'https://images.unsplash.com/photo-1517841905240-472988babdf9',
                            name: 'Darlene Robertson',
                            timeAgo: '2m ago',
                            message: '\$1250',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      style: TextStyle(
                          color: Colors.white.withOpacity(.7), fontSize: 12),
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
