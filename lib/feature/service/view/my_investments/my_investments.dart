import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../create_service/provider/investment_provider.dart';
import 'my_investment_details.dart';

class MyInvestmentScreen extends StatefulWidget {
  const MyInvestmentScreen({super.key});

  @override
  State<MyInvestmentScreen> createState() => _MyInvestmentScreenState();
}

class _MyInvestmentScreenState extends State<MyInvestmentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<InvestmentProvider>().fetchAllInvestments());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InvestmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => p.fetchAllInvestments(),
          child: Builder(
            builder: (_) {
              if (p.loadingList) return const Center(child: CircularProgressIndicator());
              if (p.error != null) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 80),
                    Text(p.error!, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => p.fetchAllInvestments(), child: const Text('Retry')),
                  ],
                );
              }
              if (p.investments.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('No investments yet', style: TextStyle(color: Colors.white70))),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: p.investments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final it = p.investments[i];

                  final status = (it.status ?? 'In Progress');
                  final statusColor = status.toLowerCase().contains('complete')
                      ? const Color(0xFF58D38C)
                      : const Color(0xFFFF8A34);

                  final progress = ((it.progress ?? 0) / 100).clamp(0, 1).toDouble();
                  final goalText = it.fundingGoal != null ? '\$${it.fundingGoal}' : '\$—';
                  final daysLeftText = it.durationDays != null ? '${it.durationDays} days left' : '—';

                  return _InvestmentCard(
                    id: it.id,
                    status: status,
                    statusColor: statusColor,
                    networkImageUrl: it.imageUrl,             // ✅ show server image if present
                    fallbackAsset: 'assets/images/agriculture.jpg',
                    category: it.category.isEmpty ? '—' : it.category,
                    title: it.name,
                    description: it.description,
                    progress: progress,
                    goalText: goalText,
                    daysLeftText: daysLeftText,
                    showCompleted: status.toLowerCase().contains('complete'),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String id;
  final String status;
  final Color statusColor;
  final String? networkImageUrl; // may be null
  final String fallbackAsset;
  final String category;
  final String title;
  final String description;
  final double progress;
  final String goalText;
  final String daysLeftText;
  final bool showCompleted;

  const _InvestmentCard({
    required this.id,
    required this.status,
    required this.statusColor,
    required this.networkImageUrl,
    required this.fallbackAsset,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    required this.goalText,
    required this.daysLeftText,
    required this.showCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = const Color(0xFF15181C);
    final accent = const Color(0xFFFF8A34);

    final prov = context.watch<InvestmentProvider>();
    final isDeleting = prov.deletingIds.contains(id);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242931)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          // Image + status badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: networkImageUrl == null
                      ? Image.asset(
                    fallbackAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _brokenImage(),
                  )
                      : Image.network(
                    networkImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, w, progress) {
                      if (progress == null) return w;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => _brokenImage(),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.7)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.2),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),

                // ✅ exactly 3 lines
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5, height: 1.35),
                ),

                const SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressBar(
                      value: progress,
                      background: const Color(0xFF1E232A),
                      fill: const Color(0xFFFF8A00),
                      height: 10,
                      radius: 6,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).round()}% of $goalText',
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          daysLeftText,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                            final disabled = states.contains(WidgetState.disabled);
                            return BorderSide(color: const Color(0xFFFF6A00).withOpacity(disabled ? 0.45 : 1), width: 1.5);
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            final disabled = states.contains(WidgetState.disabled);
                            return const Color(0xFFFF6A00).withOpacity(disabled ? 0.45 : 1);
                          }),
                          overlayColor: WidgetStateProperty.all(const Color(0xFFFF6A00).withOpacity(0.08)),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                        ),
                        onPressed: (showCompleted || isDeleting)
                            ? null
                            : () async {
                          final ok = await context.read<InvestmentProvider>().deleteInvestment(id);
                          if (ok) {
                            Get.snackbar('Deleted', 'Investment removed', snackPosition: SnackPosition.BOTTOM);
                          } else {
                            final msg = context.read<InvestmentProvider>().error ?? 'Failed to delete';
                            Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                        child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.to(
                                () => MyInvestmentDetailScreen(investmentId: id),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('View Details'),
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

  Widget _brokenImage() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image_outlined, color: Colors.white70),
  );
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color background;
  final Color fill;
  final double height;
  final double radius;

  const _ProgressBar({
    required this.value,
    required this.background,
    required this.fill,
    this.height = 10,
    this.radius = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: background,
        valueColor: AlwaysStoppedAnimation<Color>(fill),
      ),
    );
  }
}


