import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../providers/investment_provider.dart';
import '../../../models/investment.dart';
import 'my_investment_details.dart';

class MyInvestmentScreen extends StatefulWidget {
  const MyInvestmentScreen({super.key, this.items}); // items unused now (API)

  /// (Optional legacy) inject your own items. When null we use API data.
  final List<InvestmentItem>? items;

  @override
  State<MyInvestmentScreen> createState() => _MyInvestmentScreenState();
}

class _MyInvestmentScreenState extends State<MyInvestmentScreen> {
  @override
  void initState() {
    super.initState();
    // initial load (safe to call in initState)
    Future.microtask(() => context.read<InvestmentProvider>().fetch(page: 1));
  }

  Future<void> _refresh() => context.read<InvestmentProvider>().refresh();

  InvestmentItem _mapToItem(Investment inv) {
    final imgUrl = (inv.images.isNotEmpty) ? inv.images.first.url : null;
    return InvestmentItem(
      id: inv.id,
      name: inv.name,
      description: inv.description,
      fundingGoal: inv.fundingGoal,
      progressPct: inv.progressPct ?? 0,
      daysLeft: inv.daysLeft,
      category: inv.category.isNotEmpty ? inv.category.first : '',
      // status: inv.status ?? 'In Progress',
      imageUrl: imgUrl,
      imageAsset: imgUrl == null ? 'assets/images/agriculture.jpg' : null,
      location: inv.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InvestmentProvider>();


    return Scaffold(

      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Builder(

            builder: (_) {
              if (prov.loading && prov.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if ((prov.error?.isNotEmpty ?? false) && prov.items.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      prov.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => prov.fetch(page: 1),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              if (prov.items.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Text(
                        'No investments yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                );
              }

              final uiItems = prov.items.map(_mapToItem).toList();

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: uiItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final it = uiItems[i];

                  final status = it.status ?? 'In Progress';
                  final statusColor = status.toLowerCase().contains('complete')
                      ? const Color(0xFF58D38C)
                      : const Color(0xFFFF8A34);

                  final progress = ((it.progressPct ?? 0) / 100)
                      .clamp(0, 1)
                      .toDouble();
                  final goalText = it.fundingGoal != null
                      ? '\$${_comma(it.fundingGoal!)}'
                      : '\$—';
                  final daysLeftText = it.daysLeft != null
                      ? '${it.daysLeft} days left'
                      : '—';

                  return _InvestmentCard(
                    status: status,
                    statusColor: statusColor,
                    networkImageUrl: it.imageUrl,
                    fallbackAsset:
                        it.imageAsset ?? 'assets/images/agriculture.jpg',
                    category: it.category ?? '',
                    title: it.name ?? '—',
                    description: it.description ?? '—',
                    progress: progress,
                    goalText: goalText,
                    daysLeftText: daysLeftText,
                    showCompleted: status.toLowerCase().contains('complete'),
                    onDelete: () async {
                      final ok =
                          await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete investment?'),
                              content: const Text(
                                'This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (!ok) return;

                      await context.read<InvestmentProvider>().delete(it.id);
                      final err = context.read<InvestmentProvider>().error;
                      if (err != null) {
                        Get.snackbar(
                          'Error',
                          err,
                          snackPosition: SnackPosition.TOP,
                        );
                      } else {
                        Get.snackbar(
                          'Deleted',
                          'Investment removed',
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    onView: () {
                      Get.to(
                        () => MyInvestmentDetailScreen(
                          investmentId: it.id,
                          detail: it.toDetail(),
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
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

// -------------------- UI (unchanged visuals) --------------------
class _InvestmentCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String? networkImageUrl; // may be null
  final String fallbackAsset;
  final String category;
  final String title;
  final String description;
  final double progress; // 0..1
  final String goalText;
  final String daysLeftText;
  final bool showCompleted;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _InvestmentCard({
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
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF15181C);
    const accent = Color(0xFFFF8A34);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242931)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                          loadingBuilder: (c, w, ev) => ev == null
                              ? w
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          errorBuilder: (_, __, ___) => _brokenImage(),
                        ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.7)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
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
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          daysLeftText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
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
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          side: WidgetStateProperty.resolveWith<BorderSide>((
                            states,
                          ) {
                            final disabled = states.contains(
                              WidgetState.disabled,
                            );
                            return BorderSide(
                              color: const Color(
                                0xFFFF6A00,
                              ).withOpacity(disabled ? 0.45 : 1),
                              width: 1.5,
                            );
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                                final disabled = states.contains(
                                  WidgetState.disabled,
                                );
                                return const Color(
                                  0xFFFF6A00,
                                ).withOpacity(disabled ? 0.45 : 1);
                              }),
                          overlayColor: WidgetStateProperty.all(
                            const Color(0xFFFF6A00).withOpacity(0.08),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        onPressed: showCompleted ? null : onDelete,
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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
                        onPressed: onView,
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

// ---------- Local model & helpers kept for detail screen ----------
class InvestmentItem {
  final String id;
  final String? name;
  final String? description;
  final int? fundingGoal; // USD
  final int? progressPct; // 0..100
  final int? daysLeft;
  final String? category;
  final String? status;
  final String? imageUrl; // network
  final String? imageAsset; // local asset
  final String? location;

  const InvestmentItem({
    required this.id,
    this.name,
    this.description,
    this.fundingGoal,
    this.progressPct,
    this.daysLeft,
    this.category,
    this.status,
    this.imageUrl,
    this.imageAsset,
    this.location,
  });

  InvestmentDetail toDetail() => InvestmentDetail(
    name: name,
    category: category,
    location: location,
    description: description,
    terms:
        'Min ticket: \$100\nTarget ROI: 8–12%\nLock-up: 12 months\nDividends paid quarterly',
    fundingGoal: fundingGoal,
    progressPct: progressPct,
    daysLeft: daysLeft,
    imageUrl: imageUrl,
    imageAsset: imageAsset,
    gallery: const [],
  );
}

String _comma(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[i]);
    final left = s.length - i - 1;
    if (left % 3 == 0 && left != 0) b.write(',');
  }
  return b.toString();
}
