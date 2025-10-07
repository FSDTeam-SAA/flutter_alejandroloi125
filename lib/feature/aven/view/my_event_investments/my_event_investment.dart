import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/investment.dart' as detail;
import 'my_event_investment_detail.dart' as detail;

// ------- Theme -------
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;
const _barTrack = Color(0xFF3A3A3E);
const _btnDark = Color(0xFF2A2B30);

/// Pure UI screen — no API/Provider integration (unchanged).
/// Pass a pre-fetched list of [detail.Investment]s from the caller.
class MyEventInvestmentScreen extends StatelessWidget {
  const MyEventInvestmentScreen({
    super.key,
    this.investments = const [],
    this.onDelete, // optional: delete callback
  });

  /// Provide pre-fetched investments (no API/provider here).
  final List<detail.Investment> investments;

  /// Optional delete action. If null, the Delete button will be disabled.
  final void Function(detail.Investment it)? onDelete;

  @override
  Widget build(BuildContext context) {


    if (investments.isEmpty) {
      // debugPrint(investments.isEmpty as String?);
      return const Center(
        child: Text('No investments found',
            style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: investments.length,
      itemBuilder: (context, i) {
        final it = investments[i];

        final image = it.primaryImageUrl ?? 'assets/images/wind-mill.jpg';
        final amountStr = _fmtMoney(it.fundingGoal ?? 0); // "$25,000"
        final progressPct = (it.progressPct).clamp(0, 100); // 0..100
        final progress = progressPct / 100.0;              // 0..1
        final daysStr =
        it.daysLeft == null ? '0 days left' : '${it.daysLeft} days left';
        final statusText = progress >= 1 ? 'Completed' : 'In Progress';
        final isCompleted = progress >= 1;

        return _InvestmentCard(
          image: image,
          status: statusText,
          statusColor: isCompleted ? const Color(0xFF4CAF50) : _accent,
          category:
          it.category.isNotEmpty ? it.category.first : 'Agriculture',
          title: it.name,
          description: it.description,
          progress: progress,
          amount: amountStr,
          daysLeft: daysStr,
          onDelete: onDelete == null ? null : () => onDelete!(it),
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
  final String? status; // "In Progress", "Completed", etc.
  final Color? statusColor;
  final double progress; // 0..1
  final VoidCallback onView;
  final VoidCallback? onDelete;

  const _InvestmentCard({
    required this.image,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    required this.amount,
    required this.daysLeft,
    required this.onView,
    this.onDelete,
    this.status,
    this.statusColor,
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
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image + badge
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                _CardImage(image),
                if (status != null && status!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (statusColor ?? _accent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        height: 1.1)),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                  const TextStyle(color: _textDim, fontSize: 13.5, height: 1.25),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Label(text: pctText, strong: true)),
                    Text(daysLeft,
                        style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, c) => Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: _barTrack,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      Container(
                        height: 6,
                        width: (c.maxWidth * progress).clamp(0.0, c.maxWidth),
                        decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // buttons row: Delete + View Details
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _btnDark,
                          side: const BorderSide(color: _barTrack, width: 1.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size.fromHeight(42),
                        ),
                        child: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onView,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size.fromHeight(42),
                          elevation: 0,
                        ),
                        child: const Text('View Details',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
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

// ----- helpers -----
String _fmtMoney(int v) {
  // "$25,000" without intl
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    b.write(s[i]);
    final isThousandBreak = (idxFromEnd > 1) && ((idxFromEnd - 1) % 3 == 0);
    if (isThousandBreak) b.write(',');
  }
  return '\$${b.toString()}';
}
