

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_event_investment_detail.dart';

// ------- Theme (kept consistent with your other screens) -------
const _bg = Color(0xFF000000);
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;
const _barTrack = Color(0xFF3A3A3E);

class MyEventInvestmentScreen extends StatelessWidget {
  const MyEventInvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: const [
        _InvestmentCard(
          image: 'assets/images/garden.jpg',
          category: 'Agriculture',
          title: 'Urban Farming Initiative',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          progress: 1.00, // 100%
          amount: '\$25,000',
          daysLeft: '10 days left',
        ),
        _InvestmentCard(
          image: 'assets/images/diamond.jpg',
          category: 'Agriculture',
          title: 'Urban Farming Initiative',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          progress: 0.45, // 45%
          amount: '\$25,000',
          daysLeft: '10 days left',
        ),
        _InvestmentCard(
          image: 'assets/images/wind-mill.jpg',
          category: 'Agriculture',
          title: 'Urban Farming Initiative',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          progress: 0.60, // 60%
          amount: '\$25,000',
          daysLeft: '10 days left',
        ),
      ],
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final String description;
  final double progress; // 0.0 - 1.0
  final String amount;
  final String daysLeft;

  const _InvestmentCard({
    required this.image,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    required this.amount,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${(progress * 100).round()}% of $amount';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(image, height: 168, width: double.infinity, fit: BoxFit.cover),
          ),

          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // category
                Text(
                  category,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                // description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textDim, fontSize: 13.5, height: 1.25),
                ),
                const SizedBox(height: 12),

                // progress labels
                Row(
                  children: [
                    Expanded(
                      child: _Label(text: pctText, strong: true),
                    ),
                    Text(daysLeft, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),

                // progress bar
                LayoutBuilder(
                  builder: (context, c) => Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _barTrack,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: (c.maxWidth * progress).clamp(0.0, c.maxWidth),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // view details (outlined full-width)
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(
                        const MyEventInvestmentDetail(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _accent, width: 1.2),
                      foregroundColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class _Label extends StatelessWidget {
  final String text;
  final bool strong;
  const _Label({required this.text, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: strong ? Colors.white : _textDim,
        fontSize: 12.5,
        fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
