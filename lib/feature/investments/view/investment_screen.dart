// lib/investments_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'investment_detail.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F0F12);
    const card = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent = Color(0xFFFF7A1A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Investments',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: card,
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              // Top bar
              Row(
                children: [
                  _IconBtn(
                    onTap: () {},
                    child: const Icon(CupertinoIcons.back, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Investments',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const Spacer(),
                  const Icon(CupertinoIcons.battery_100), // just to match status-ish
                ],
              ),
              const SizedBox(height: 12),

              // Search + Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.search,
                              color: Colors.white.withOpacity(.7), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search location',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(.6),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _IconBtn(
                    onTap: () {},
                    child: const Icon(CupertinoIcons.slider_horizontal_3, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Cards
              InkWell(
                onTap: (){
                  Get.to(InvestmentDetailScreen());
                },
                child: _InvestmentCard(
                  image:
                  'assets/images/agriculture.jpg',
                  category: 'Agriculture',
                  title: 'Urban Farming Initiative',
                  description:
                  'Looking for an experienced web designer to revamp our company website. Need',
                  progressPct: 45,
                  goalUsd: 25000,
                  daysLeft: 10,
                  ownerAvatar: 'https://i.pravatar.cc/100?img=13',
                  ownerName: 'John Smith',
                ),
              ),
              const SizedBox(height: 14),
              _InvestmentCard(
                image:
                'https://images.unsplash.com/photo-1509395176047-4a66953fd231?q=80&w=1200&auto=format&fit=crop',
                category: 'Agriculture',
                title: 'Urban Farming Initiative',
                description:
                'Looking for an experienced web designer to revamp our company website. Need',
                progressPct: 45,
                goalUsd: 25000,
                daysLeft: 10,
                ownerAvatar: 'https://i.pravatar.cc/100?img=15',
                ownerName: 'John Smith',
              ),
              const SizedBox(height: 14),
              _InvestmentCard(
                image:
                'https://images.unsplash.com/photo-1524404794195-0f93a1c1a5a5?q=80&w=1200&auto=format&fit=crop',
                category: 'Agriculture',
                title: 'Urban Farming Initiative',
                description:
                'Looking for an experienced web designer to revamp our company website. Need',
                progressPct: 45,
                goalUsd: 25000,
                daysLeft: 10,
                ownerAvatar: 'https://i.pravatar.cc/100?img=21',
                ownerName: 'John Smith',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E23),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final String description;
  final int progressPct;
  final int goalUsd;
  final int daysLeft;
  final String ownerAvatar;
  final String ownerName;

  const _InvestmentCard({
    required this.image,
    required this.category,
    required this.title,
    required this.description,
    required this.progressPct,
    required this.goalUsd,
    required this.daysLeft,
    required this.ownerAvatar,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent = Color(0xFFFF7A1A);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Ink.image(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.65), fontSize: 12)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.72), fontSize: 12),
                ),
                const SizedBox(height: 10),

                // progress row
                Container(
                  decoration: BoxDecoration(
                    color: inner,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _ProgressBar(
                              value: progressPct / 100,
                              color: accent,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${progressPct}% of \$${_fmt(goalUsd)}',
                                  style: TextStyle(
                                      color:
                                      Colors.white.withOpacity(.75),
                                      fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  '$daysLeft days left',
                                  style: TextStyle(
                                      color:
                                      Colors.white.withOpacity(.75),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Owner row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(ownerAvatar),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(ownerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    Container(
                      height: 36,
                      width: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: inner,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.chevron_right, size: 18),
                    ),
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

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(.12);
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(
          children: [
            Container(color: bg),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// --- helpers
String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) buf.write(',');
  }
  return buf.toString();
}
