import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'auction_screen.dart';

// void main() => runApp(const AuctionDetailScreen());

class AuctionDetailScreen extends StatelessWidget {
  const AuctionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auction Detail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8C3B), // accent orange
          secondary: Color(0xFF2A2B30),
          surface: Color(0xFF1A1B1E),
        ),
        dividerColor: const Color(0xFF2B2C31),
        useMaterial3: true,
      ),
      home: const AuctionDetailPage(),
    );
  }
}

class AuctionDetailPage extends StatefulWidget {
  const AuctionDetailPage({super.key});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  late final DateTime endTime;
  late final Stream<String> timer$;
  final bidCtrl = TextEditingController(text: '1250+');
  final msgCtrl = TextEditingController();

  final List<ChatMessage> messages = [
    ChatMessage(
      name: 'Ronald Richards',
      avatar: 'https://i.pravatar.cc/100?img=14',
      timeAgo: '2m ago',
      text: r'$500',
    ),
    ChatMessage(
      name: 'Arlene McCoy',
      avatar: 'https://i.pravatar.cc/100?img=36',
      timeAgo: '2m ago',
      text: r'$600',
    ),
    ChatMessage(
      name: 'Darrell Stewart',
      avatar: 'https://i.pravatar.cc/100?img=22',
      timeAgo: '2m ago',
      text: "What's the band material?",
    ),
    ChatMessage(
      name: 'Kathryn Murphy',
      avatar: 'https://i.pravatar.cc/100?img=57',
      timeAgo: '2m ago',
      text: r'$1000',
    ),
    ChatMessage(
      name: 'Devon Lane',
      avatar: 'https://i.pravatar.cc/100?img=47',
      timeAgo: '2m ago',
      text: 'Beautiful !',
    ),
    ChatMessage(
      name: 'Robert Fox',
      avatar: 'https://i.pravatar.cc/100?img=33',
      timeAgo: '2m ago',
      text: "I'll go \$1,200",
    ),
    ChatMessage(
      name: 'Darlene Robertson',
      avatar: 'https://i.pravatar.cc/100?img=4',
      timeAgo: '2m ago',
      text: r'$1250',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // countdown ~3 minutes from now (matches mock "Ends in: 2:57")
    endTime = DateTime.now().add(const Duration(minutes: 3));
    timer$ = Stream.periodic(const Duration(seconds: 1), (_) {
      final diff = endTime.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final m = diff.inMinutes.remainder(60).toString().padLeft(1, '0');
      final s = (diff.inSeconds.remainder(60)).toString().padLeft(2, '0');
      return '$m:$s';
    });
  }

  @override
  void dispose() {
    bidCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  void _placeBid() {
    FocusScope.of(context).unfocus();
    final raw = bidCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) {
      _toast('Enter a valid bid');
      return;
    }
    _toast('Bid placed: \$$raw');
  }

  void _sendMessage() {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(ChatMessage(
        name: 'You',
        avatar: 'https://i.pravatar.cc/100?img=1',
        timeAgo: 'now',
        text: text,
      ));
    });
    msgCtrl.clear();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Collapsing header with image =======
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?q=80&w=1600&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  // gradient overlay
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
                  // Top actions
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _circleBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () {
                            Get.off(
                                  () =>  AuctionScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                        const Spacer(),
                        _circleBtn(icon: Icons.share_outlined, onTap: () {}),
                        const SizedBox(width: 10),
                        _circleBtn(
                            icon: Icons.favorite_border_rounded, onTap: () {}),
                      ],
                    ),
                  ),
                  // LIVE badge
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 56),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 10, color: Colors.white),
                          SizedBox(width: 6),
                          Text('LIVE',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  // Seller row and metrics
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage:
                          NetworkImage('https://i.pravatar.cc/100?img=12'),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Eleanor Pena',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('@eleanorpena',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70)),
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
            // ======= Body =======
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Gaming Console',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      StreamBuilder<String>(
                        stream: timer$,
                        initialData: '3:00',
                        builder: (_, snap) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
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
                                fontSize: 12.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 16),
                  // Current bid block
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Current Bid',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text('\$1,200',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w900)),
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
                            filled: true,
                            fillColor: ThemeData.dark()
                                .colorScheme
                                .secondary, // matches theme
                            hintText: '1250+',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _placeBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Bid',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Live Chat header
                  Row(
                    children: const [
                      Icon(Icons.chat_bubble_outline_rounded),
                      SizedBox(width: 8),
                      Text('Live Chat',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Chat box
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final m = messages[i];
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
                                        child: Text(m.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                      ),
                                      Text(m.timeAgo,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(m.text,
                                      style: const TextStyle(height: 1.25)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 90), // leave space for input bar
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
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                width: 56,
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== helpers & models ======

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

class ChatMessage {
  final String name;
  final String avatar;
  final String timeAgo;
  final String text;

  ChatMessage({
    required this.name,
    required this.avatar,
    required this.timeAgo,
    required this.text,
  });
}
