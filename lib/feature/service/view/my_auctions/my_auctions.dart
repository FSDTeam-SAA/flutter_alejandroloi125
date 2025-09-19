import 'package:alejandroloi/feature/auctions/view/auction_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'my_auction_details.dart';

class MyAuctionScreen extends StatelessWidget {
  const MyAuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            _AuctionCard(
              imageUrl:
              'assets/images/watch.jpg', // replace with asset
              title: 'Gaming Console',
              priceLabel: '\$1,200',
              timeLabel: '2 weeks',
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              completed: false,
            ),
            SizedBox(height: 14),
            _AuctionCard(
              imageUrl:
              'assets/images/diamond.jpg', // replace with asset
              title: 'Gaming Console',
              priceLabel: '\$1,200',
              timeLabel: '2 weeks',
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              completed: false,
            ),
            SizedBox(height: 14),
            _AuctionCard(
              imageUrl:
              'assets/images/earpod.jpg', // replace with asset
              title: 'Gaming Console',
              priceLabel: 'Final: \$1,200',
              timeLabel: 'Finished May 15',
              status: 'Completed',
              statusColor: Color(0xFF58D38C),
              completed: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String priceLabel;
  final String timeLabel;
  final String status;
  final Color statusColor;
  final bool completed;

  const _AuctionCard({
    required this.imageUrl,
    required this.title,
    required this.priceLabel,
    required this.timeLabel,
    required this.status,
    required this.statusColor,
    required this.completed,
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
          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),

          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title / badge row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.7)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // time row
                _InfoBar(icon: Icons.access_time, label: timeLabel),
                const SizedBox(height: 12),

                // buttons
                if (!completed)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                            foregroundColor: Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {},
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: () {

                            Get.to(
                                  () => const MyAuctionDetailScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300), // optional
                              curve: Curves.easeInOut,                     // optional
                            );

                          },
                          child: const Text('View Details'),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text('View Details'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
      child: Row(
        children: [
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
        ],
      ),
    );
  }
}
