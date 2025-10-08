import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../../../providers/project_provider.dart';
import '../../../models/project.dart';
import 'my_event_project_details.dart';
import 'package:alejandroloi/core/network/api_service/token_store.dart'; // read user id

const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;

class MyEventProject extends StatefulWidget {
  const MyEventProject({super.key});
  @override
  State<MyEventProject> createState() => _MyEventProjectState();
}

class _MyEventProjectState extends State<MyEventProject> {
  final _scroll = ScrollController();
  final _store  = TokenStore();
  bool _paging = false;
  String? _userId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userId = await _store.readUserId();
      if (!mounted) return;

      if (_userId == null || _userId!.isEmpty) {
        Get.snackbar('Auth required', 'Please log in again',
            snackPosition: SnackPosition.TOP);
        return;
      }
      context.read<ProjectProvider>().fetchMine(_userId!, page: 1, limit: 10);
    });

    _scroll.addListener(() {
      final prov = context.read<ProjectProvider>();
      if (_paging || prov.loading || _userId == null) return;

      final nearBottom =
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120;

      if (nearBottom && prov.page < prov.pages) {
        _paging = true;
        prov.fetchMoreMine(_userId!, limit: 10).whenComplete(() {
          _paging = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProjectProvider>();
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
        child: Text('No projects found', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
        final p = items[i];
        return _ProjectCard(
          p: p,
          onTap: () async {
            final changed = await Get.to(
                  () => MyEventProjectDetail(projectId: p.id),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 320),
            );

            if (changed == true) {
              // Provider already updated its local list in update(); this forces rebuild.
              setState(() {});
              // Or if you prefer refetch from server:
              // if (_userId != null) context.read<ProjectProvider>().fetchMine(_userId!, page: 1, limit: 10);
            }
          },
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project p;
  final VoidCallback? onTap;
  const _ProjectCard({required this.p, this.onTap});

  @override
  Widget build(BuildContext context) {
    final styles = _statusStyle(p.status);
    final pillText = _statusLabel(p.status);
    final budgetRange = _budgetRange(p.minBudget, p.maxBudget);
    final duration = p.deadlineDays > 0 ? '${p.deadlineDays} Days' : '-';
    final skillsText = p.skills.isEmpty
        ? 'No skills'
        : (p.skills.length <= 3 ? p.skills.join(', ') : '${p.skills.length} skills');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.category,
                    style: const TextStyle(
                      color: _accent, fontSize: 12, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (pillText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: styles.bg, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        pillText,
                        style: TextStyle(color: styles.fg, fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                p.title,
                style: const TextStyle(
                  color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800, height: 1.1,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                p.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _textDim, fontSize: 13.5, height: 1.25),
              ),
              const SizedBox(height: 10),

              _InfoRow(
                leftIcon: Icons.attach_money, leftText: budgetRange,
                rightIcon: Icons.schedule, rightText: duration,
              ),
              const SizedBox(height: 6),
              _InfoRow(
                leftIcon: Icons.location_on_outlined, leftText: p.location,
                rightIcon: Icons.badge_outlined, rightText: skillsText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- shared bits ----------
class _InfoRow extends StatelessWidget {
  final IconData leftIcon;
  final String leftText;
  final IconData rightIcon;
  final String rightText;

  const _InfoRow({
    required this.leftIcon, required this.leftText,
    required this.rightIcon, required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(leftIcon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(leftText,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(rightIcon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Flexible(
                child: Text(rightText,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  const _StatusStyle(this.bg, this.fg);
}

_StatusStyle _statusStyle(String? status) {
  final s = (status ?? '').toLowerCase();
  switch (s) {
    case 'complete':
    case 'completed':
      return const _StatusStyle(Color(0x332AA86F), Color(0xFF2AA86F)); // green
    case 'accepted':
      return const _StatusStyle(Color(0x332E8BFD), Color(0xFF2E8BFD)); // blue
    case 'process':
      return const _StatusStyle(Color(0x33FFA000), Color(0xFFFFA000)); // amber
    case 'declined':
      return const _StatusStyle(Color(0x33E53935), Color(0xFFE53935)); // red
    case 'pending':
      return const _StatusStyle(Color(0x33424242), Colors.white70);    // gray
    default:
      return const _StatusStyle(Color(0x33424242), Colors.white70);
  }
}

String _statusLabel(String? raw) {
  final s = (raw ?? '').toLowerCase().trim();
  if (s.isEmpty) return '';
  if (s == 'complete' || s == 'completed') return 'Completed';
  if (s == 'process') return 'Process';
  if (s == 'pending') return 'Pending';
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

String _budgetRange(int min, int max) {
  if (min == 0 && max == 0) return '-';
  if (min > 0 && max > 0) return '\$ ${_comma(min)} - ${_comma(max)}';
  if (min > 0) return 'From \$ ${_comma(min)}';
  return 'Up to \$ ${_comma(max)}';
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
