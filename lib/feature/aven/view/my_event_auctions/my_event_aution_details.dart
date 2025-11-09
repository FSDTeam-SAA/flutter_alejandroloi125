import 'package:alejandroloi/core/language/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auction_provider.dart';
import '../../../models/auction.dart';
import 'my_event_auction_purchase.dart';

/// Color palette
const _bg = Color(0xFF2B2B2E);
const _card = Color(0xFF1E1F22);
const _pillGreen = Color(0xFF2AA86F);
const _accent = Color(0xFFFF7A00);

class MyEventAutionDetailScreen extends StatefulWidget {
  final String auctionId;
  const MyEventAutionDetailScreen({super.key, required this.auctionId});

  @override
  State<MyEventAutionDetailScreen> createState() =>
      _MyEventAutionDetailScreenState();
}

class _MyEventAutionDetailScreenState extends State<MyEventAutionDetailScreen> {
  AuctionDto? _auction;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final a = await context.read<AuctionProvider>().one(widget.auctionId);
        if (!mounted) return;
        setState(() {
          _auction = a;
          _loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, style: const TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }

    final a = _auction!;
    final headerUrl = (a.image.isNotEmpty && a.image.first.url.isNotEmpty)
        ? a.image.first.url
        : null;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // Top app bar with title
            SliverAppBar(
              pinned: true,
              backgroundColor: _bg,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
              title: Text(
                languageController.t('auctions_details'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Header image with heart
            SliverToBoxAdapter(child: _Header(imageUrl: headerUrl)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Details card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _DetailsCard(
                  title: a.name,
                  description: a.description,
                  finalBidText: _money(a.startingBid),
                  statusText: 'Won',
                  auctionId: a.id,
                  finalBidAmount: a.startingBid.round(),
                  imageUrl: headerUrl, // pass to purchase screen
                  itemTitle: a.name, // pass to purchase screen
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Live chat (demo)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _LiveChatSection(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? imageUrl;
  const _Header({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final languageController = Get.find<LanguageController>();

    return AspectRatio(
      aspectRatio: 375 / 228,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image (network -> asset fallback)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: imageUrl == null || imageUrl!.isEmpty
                ? Image.asset('assets/images/earpod.jpg', fit: BoxFit.cover)
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/earpod.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          // Gradient overlay
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

          // “LIVE” pill
          Positioned(
            top: topInset + 28,
            left: 0,
            right: 0,
            child: const Align(
              alignment: Alignment.topCenter,
              child: _LivePill(),
            ),
          ),

          // Heart over image (top-right)
          Positioned(
            top: topInset + 12,
            right: 12,
            child: _RoundIconButton(
              icon: Icons.favorite_border,
              onTap: () {
                // TODO: toggle favorite
              },
            ),
          ),

          // Creator + stats (demo)
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
  final String title;
  final String description;
  final String finalBidText;
  final String statusText;

  // these let us pass data to the purchase screen
  final String auctionId;
  final int finalBidAmount;
  final String? imageUrl;
  final String? itemTitle;

  const _DetailsCard({
    required this.title,
    required this.description,
    required this.finalBidText,
    required this.statusText,
    required this.auctionId,
    required this.finalBidAmount,
    this.imageUrl,
    this.itemTitle,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _pillGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: 0.9,
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Final bid + CTA
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      '${languageController.t('bid')}:',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    finalBidText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ],
              ),
              const Spacer(),
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
                      _slideRightToLeft(
                        MyEventAuctionPurchase(
                          auctionId: auctionId,
                          amount: finalBidAmount,
                          imageUrl: imageUrl,
                          itemTitle: itemTitle,
                        ),
                      ),
                    );
                  },
                  child: Text(languageController.t('purchase')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- Live Chat (demo) ----------------
class _LiveChatSection extends StatefulWidget {
  const _LiveChatSection();

  @override
  State<_LiveChatSection> createState() => _LiveChatSectionState();
}

class _LiveChatSectionState extends State<_LiveChatSection> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      'Ronald Richards',
      '\$500',
      '2m ago',
      'assets/images/person.png',
    ),
    ChatMessage('Arlene McCoy', '\$800', '2m ago', 'assets/images/person.png'),
    ChatMessage(
      'Darrell Steward',
      "What's the band material?",
      '2m ago',
      'assets/images/person.png',
    ),
    ChatMessage(
      'Kathryn Murphy',
      '\$1000',
      '2m ago',
      'assets/images/person.png',
    ),
    ChatMessage(
      'Devon Lane',
      'Beautiful !',
      '2m ago',
      'assets/images/person.png',
    ),
    ChatMessage(
      'Robert Fox',
      "I'll go \$1,200",
      '2m ago',
      'assets/images/person.png',
    ),
    ChatMessage(
      'Darlene Robertson',
      '\$1250',
      '2m ago',
      'assets/images/person.png',
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  languageController.t('live_chat'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.white24),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => _ChatRow(message: _messages[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: _messages.length,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: languageController.t('enter_type_message'),
                      hintStyle: const TextStyle(color: Colors.white70),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF2B2C30),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
      _messages.add(
        ChatMessage('You', text, 'now', 'assets/images/person.png'),
      );
    });
    _controller.clear();
  }
}

// ---------------- Reusable bits ----------------
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
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
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
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
      final tween = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// ---- formatting helper ----
String _money(num n) {
  final s = n.toStringAsFixed(0);
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[i]);
    final left = s.length - i - 1;
    if (left % 3 == 0 && left != 0) b.write(',');
  }
  return '\$$b';
}
