import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_event_investment_detail.dart' as detail;

// ------- Theme -------
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;
const _barTrack = Color(0xFF3A3A3E);

/// Pure UI screen — no API/Provider integration.
/// Pass a pre-fetched list of [detail.Investment]s from the caller.
class MyEventInvestmentScreen extends StatelessWidget {
  const MyEventInvestmentScreen({
    super.key,
    this.investments = const [],
  });

  /// Provide pre-fetched investments (no API/provider here).
  final List<detail.Investment> investments;

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return const Center(
        child: Text('No investments found', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: investments.length,
      itemBuilder: (context, i) {
        final it = investments[i];
        final amountStr = '\$${it.fundingGoal.toStringAsFixed(0)}';
        final daysStr = '${it.daysLeft} days left';

        return _InvestmentCard(
          image: it.images.isNotEmpty ? it.images.first : 'assets/images/wind-mill.jpg',
          category: it.category.isNotEmpty ? it.category.first : 'General',
          title: it.name,
          description: it.description,
          progress: it.progress.clamp(0, 1),
          amount: amountStr,
          daysLeft: daysStr,
          onView: () => Get.to(
                () => detail.MyEventInvestmentDetail(investment: it),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          ),
        );
      },
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String image, category, title, description, amount, daysLeft;
  final double progress; // 0..1
  final VoidCallback onView;

  const _InvestmentCard({
    required this.image,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    required this.amount,
    required this.daysLeft,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${(progress * 100).round()}% of $amount';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: _CardImage(image),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textDim, fontSize: 13.5, height: 1.25),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Label(text: pctText, strong: true)),
                    Text(daysLeft, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, c) => Stack(
                    children: [
                      Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: _barTrack, borderRadius: BorderRadius.circular(6))),
                      Container(
                        height: 6,
                        width: (c.maxWidth * progress).clamp(0.0, c.maxWidth),
                        decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _accent, width: 1.2),
                      foregroundColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w700)),
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

class _CardImage extends StatelessWidget {
  final String src;
  const _CardImage(this.src);

  @override
  Widget build(BuildContext context) {
    final isNet = src.startsWith('http');
    return SizedBox(
      height: 168,
      width: double.infinity,
      child: isNet
          ? Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Colors.black26,
          child: Center(child: Icon(Icons.broken_image_outlined)),
        ),
      )
          : Image.asset(src, fit: BoxFit.cover),
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
