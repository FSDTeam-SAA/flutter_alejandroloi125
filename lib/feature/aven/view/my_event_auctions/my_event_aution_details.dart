import 'package:flutter/material.dart';
import 'my_event_auction_purchase.dart';

/// Color palette tuned to the mock
const _bg = Color(0xFF2B2B2E);
const _card = Color(0xFF1E1F22);
const _pillGreen = Color(0xFF2AA86F);
const _accent = Color(0xFFFF7A00);

class MyEventAutionDetailScreen extends StatelessWidget {
  const MyEventAutionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: const [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _DetailsCard(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _LiveChatSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return AspectRatio(
      aspectRatio: 375 / 228,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Image.asset(
              'assets/images/earpod.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // GRADIENT
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),

          // TOP ICONS (left: back + share, right: heart)
          Positioned(
            top: top + 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                    ),
                    const SizedBox(width: 8),
                    // _RoundIconButton(
                    //   icon: Icons.ios_share_outlined,
                    //   onTap: () {}, // share
                    // ),
                  ],
                ),
                _RoundIconButton(
                  icon: Icons.favorite_border,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // LIVE PILL (CENTERED)
          Positioned(
            top: top + 28,
            left: 0,
            right: 0,
            child: const Align(
              alignment: Alignment.topCenter,
              child: _LivePill(),
            ),
          ),

          // CREATOR + STATS
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/person.png'),
                  backgroundColor: Colors.white12,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Eleanor Pena',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Opacity(
                        opacity: 0.85,
                        child: Text(
                          '@eleanorpena',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: const [
                    _StatPill(icon: Icons.visibility, label: '142'),
                    SizedBox(width: 8),
                    _StatPill(icon: Icons.favorite, label: '86'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Won pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Gaming Console',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _pillGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Won',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: 0.9,
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Final Bid + Purchase
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        'Final Bid:',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$1,200',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      _slideRightToLeft(const MyEventAuctionPurchase()),
                    );
                  },
                  child: const Text('Purchase'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveChatSection extends StatefulWidget {
  const _LiveChatSection();

  @override
  State<_LiveChatSection> createState() => _LiveChatSectionState();
}

class _LiveChatSectionState extends State<_LiveChatSection> {
  final List<ChatMessage> _messages = [
    ChatMessage('Ronald Richards', '\$500', '2m ago', 'assets/images/person.png'),
    ChatMessage('Arlene McCoy', '\$800', '2m ago', 'assets/images/person.png'),
    ChatMessage('Darrell Steward', "What's the band material?", '2m ago', 'assets/images/person.png'),
    ChatMessage('Kathryn Murphy', '\$1000', '2m ago', 'assets/images/person.png'),
    ChatMessage('Devon Lane', 'Beautiful !', '2m ago', 'assets/images/person.png'),
    ChatMessage('Robert Fox', "I'll go \$1,200", '2m ago', 'assets/images/person.png'),
    ChatMessage('Darlene Robertson', '\$1250', '2m ago', 'assets/images/person.png'),
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: const [
                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Live Chat',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.white24),

          // messages list
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => _ChatRow(message: _messages[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: _messages.length,
          ),
          const SizedBox(height: 4),

          // input
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF2B2C30),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  width: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _send,
                    child: const Icon(Icons.near_me_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage('You', text, 'now', 'assets/images/person.png'));
    });
    _controller.clear();
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // white ring with red dot
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String user;
  final String text;
  final String time;
  final String avatarAsset;
  ChatMessage(this.user, this.text, this.time, this.avatarAsset);
}

class _ChatRow extends StatelessWidget {
  final ChatMessage message;
  const _ChatRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage(message.avatarAsset),
          backgroundColor: Colors.white12,
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
                      message.user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      message.time,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---- route helper (right -> left) ----
Route _slideRightToLeft(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}




