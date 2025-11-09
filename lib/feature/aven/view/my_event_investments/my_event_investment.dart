import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/network/api_service/token_store.dart';
import '../../../../providers/investment_provider.dart';
import '../../../models/investment.dart';
import 'my_event_investment_detail.dart';

const _card   = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);

class MyEventInvestmentScreen extends StatefulWidget {
  const MyEventInvestmentScreen({super.key});
  @override
  State<MyEventInvestmentScreen> createState() => _MyEventInvestmentScreenState();
}

class _MyEventInvestmentScreenState extends State<MyEventInvestmentScreen> {
  final _scroll = ScrollController();
  final _store  = TokenStore();
  String? _userId;
  bool _paging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userId = await _store.readUserId();
      if (!mounted) return;

      if ((_userId ?? '').isEmpty) {
        Get.snackbar('Auth required', 'Please log in again');
        return;
      }

      context.read<InvestmentProvider>()
          .fetchByUser(userId: _userId!, page: 1, limit: 10);
    });

    _scroll.addListener(() {
      final prov = context.read<InvestmentProvider>();
      if (_paging || prov.loading || _userId == null) return;

      final nearBottom =
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120;
      if (nearBottom && prov.page < prov.pages) {
        _paging = true;
        prov.fetchMoreByUser(userId: _userId!, limit: 10)
            .whenComplete(() => _paging = false);
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov  = context.watch<InvestmentProvider>();
    final items = prov.items;

    if (prov.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((prov.error ?? '').isNotEmpty && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(prov.error!, style: const TextStyle(color: Colors.white70)),
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(
        child: Text('No investments found', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length + (prov.page < prov.pages ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        if (i >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        final inv = items[i];
        return _InvestmentCard(
          inv: inv,
          onTap: () => Get.to(
                () => InvestmentDetails(investmentId: inv.id),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 320),
          ),
        );
      },
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment inv;
  final VoidCallback? onTap;
  const _InvestmentCard({required this.inv, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cover   = inv.primaryImageUrl;
    final title   = inv.name.trim().isEmpty ? '-' : inv.name.trim();
    final summary = inv.description.trim().isEmpty ? '—' : inv.description.trim();

    final goal = inv.fundingGoal ?? 0;
    final pct  = inv.progressPct.clamp(0, 100);
    final days = inv.daysLeft ?? _parseDays(inv.fundingDuration);
    final langController = Get.put(LanguageController());

    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((cover ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(cover!, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 //const Text('Agriculture', style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                  Text(title,
                      style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),

                  Text(title,
                      style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),

                  Text(summary,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
                  const SizedBox(height: 10),

                  // progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (pct / 100).toDouble(),
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation(_accent),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // bottom row: "xx% of $goal" | "10 days left"
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal > 0 ? '$pct% of \$${_comma(goal)}' : '$pct%',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      Text(
                        days == null ? '-' : '$days days left',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // View details button
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _accent),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onTap,
                      child:  Text(langController.t('view_details')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int? _parseDays(String? fundingDuration) {
  if (fundingDuration == null) return null;
  final m = RegExp(r'\d+').firstMatch(fundingDuration);
  return m == null ? null : int.tryParse(m.group(0)!);
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
