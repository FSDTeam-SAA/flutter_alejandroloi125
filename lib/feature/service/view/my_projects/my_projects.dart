// lib/feature/service/view/my_projects/my_project_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../providers/project_provider.dart';
import '../../../models/project.dart';
import 'my_project_details.dart';

// ======= Design tokens (from the mock) =======
const _pageBg        = Color(0xFF0D0F12);
const _cardBg        = Color(0xFF1A1B1E);
const _cardStroke    = Color(0xFF2B2C31);
const _bodyText      = Colors.white;
const _mutedText     = Colors.white70;
const _accentOrange  = Color(0xFFFF8A34);

// Status chips
const _progressFg    = _accentOrange;         // label
const _progressBg    = Color(0xFFFFE8D9);     // peach bg
const _progressBd    = Color(0xFFFFD2B8);     // peach border

const _successFg     = Color(0xFF34D6C3);     // teal label (completed)
const _successBg     = Color(0xFFE8FAF6);     // light teal bg
const _successBd     = Color(0xFFBFF3EA);     // light teal border

class MyProjectScreen extends StatefulWidget {
  const MyProjectScreen({super.key});

  @override
  State<MyProjectScreen> createState() => _MyProjectScreenState();
}

class _MyProjectScreenState extends State<MyProjectScreen> {
  final _scroll = ScrollController();
  bool _paging = false;

  @override
  void initState() {
    super.initState();

    // initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetch(page: 1, limit: 10);
    });

    // infinite scroll
    _scroll.addListener(() {
      final prov = context.read<ProjectProvider>();
      if (_paging || prov.loading) return;

      final nearBottom =
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120;

      if (nearBottom && prov.page < prov.pages) {
        _paging = true;
        prov.fetch(page: prov.page + 1, limit: 10).whenComplete(() {
          if (mounted) _paging = false;
        });
      }
    });
  }

  Future<void> _refresh() =>
      context.read<ProjectProvider>().fetch(page: 1, limit: 10);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProjectProvider>();
    final items = prov.items;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: _accentOrange,
          child: Builder(
            builder: (_) {
              // first load
              if (prov.loading && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // first load error
              if ((prov.error ?? '').isNotEmpty && items.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.error_outline,
                        color: Colors.white54, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      prov.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              // empty
              if (items.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 40),
                    Icon(Icons.inbox_outlined,
                        color: Colors.white54, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No projects yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                );
              }

              return ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: items.length + (prov.page < prov.pages ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  // paging loader row
                  if (index >= items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final p = items[index];

                  // status derivation (API-driven only)
                  final apiStatus = (p.status ?? '').trim();
                  final lower = apiStatus.toLowerCase();
                  final completed = lower.contains('complete');
                  final cancelled = lower.contains('cancel');

                  final statusLabel = apiStatus.isEmpty
                      ? (completed ? 'Completed' : 'In Progress')
                      : (apiStatus[0].toUpperCase() + apiStatus.substring(1));

                  // graceful fallbacks
                  final int d = p.deadlineDays;
                  final daysText = d > 0 ? '$d Days' : '-';

                  return _ProjectCard(
                    // content
                    category: p.category,
                    title: p.title.isEmpty ? 'Untitled' : p.title,
                    description: p.description.isEmpty ? '—' : p.description,
                    budgetRange: _fmtBudget(p.minBudget, p.maxBudget),
                    days: daysText,
                    location: p.location.isEmpty ? '—' : p.location,
                    proposals: '8 Proposals',
                    // status visuals
                    statusLabel: statusLabel,
                    statusKind: completed
                        ? _StatusKind.completed
                        : (cancelled ? _StatusKind.cancelled : _StatusKind.progress),
                    // actions
                    showDelete: !completed,
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete project?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ?? false;
                      if (!ok) return;

                      await context.read<ProjectProvider>().delete(p.id);
                      final err = context.read<ProjectProvider>().error;
                      if (err == null) {
                        Get.snackbar('Deleted', 'Project removed',
                            snackPosition: SnackPosition.BOTTOM);
                      } else {
                        Get.snackbar('Error', err,
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    onView: () {
                      Get.to(
                            () => MyProjectDetailScreen(
                          projectId: p.id,
                          project: _toMyProjectData(p),
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 280),
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

  // ---------- mapping & helpers ----------

  MyProjectData _toMyProjectData(Project p) => MyProjectData(
    id: p.id,
    category: p.category,
    title: p.title,
    description: p.description,
    budgetMin: p.minBudget,
    budgetMax: p.maxBudget,
    durationDays: p.deadlineDays,
    location: p.location,
    // proposalsCount: 8,
    createdAt: DateTime.now(),
    skills: p.skills,
  );

  String _fmtBudget(int min, int max) {
    String sep(int n) {
      final s = n.toString();
      final b = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        b.write(s[i]);
        final left = s.length - i - 1;
        if (left % 3 == 0 && left != 0) b.write(',');
      }
      return b.toString();
    }

    if (min == 0 && max == 0) return '-';
    if (min > 0 && max > 0) return '\$ ${sep(min)} - ${sep(max)}';
    if (min > 0) return '\$ ${sep(min)}+';
    return '\$ ${sep(max)}';
  }
}

// ======= Card (pixel-matched to the mock) =======

enum _StatusKind { progress, completed, cancelled }

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.category,
    required this.title,
    required this.description,
    required this.budgetRange,
    required this.days,
    required this.location,
    required this.proposals,
    required this.statusLabel,
    required this.statusKind,
    required this.showDelete,
    required this.onView,
    this.onDelete,
  });

  final String category;
  final String title;
  final String description;
  final String budgetRange;
  final String days;
  final String location;
  final String proposals;

  final String statusLabel;
  final _StatusKind statusKind;

  final bool showDelete;
  final VoidCallback? onDelete;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, bd) = switch (statusKind) {
      _StatusKind.progress   => (_progressFg, _progressBg, _progressBd),
      _StatusKind.completed  => (_successFg,  _successBg,  _successBd),
      _StatusKind.cancelled  => (Colors.white70, const Color(0xFF2A2B30), _cardStroke),
    };

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardStroke),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top spacing for status chip overlay
                const SizedBox(height: 26),

                // Category
                Text(
                  category,
                  style: const TextStyle(
                    color: _accentOrange,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _bodyText,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                // Info rows (exactly like mock: icon + text, two columns)
                _TwoCols(
                  leftIcon: Icons.attach_money_rounded,
                  leftText: budgetRange,
                  rightIcon: Icons.timelapse_rounded,
                  rightText: days,
                ),
                const SizedBox(height: 8),
                _TwoCols(
                  leftIcon: Icons.place_rounded,
                  leftText: location,
                  rightIcon: Icons.group_rounded,
                  rightText: proposals,
                ),

                const SizedBox(height: 12),
                const Divider(color: _cardStroke, height: 1),
                const SizedBox(height: 12),

                // Buttons row
                if (showDelete) Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _accentOrange, width: 2),
                          foregroundColor: _accentOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onView,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentOrange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          elevation: 0,
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentOrange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        elevation: 0,
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
              ],
            ),
          ),

          // Status chip (top-right)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bd),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Two-column row with icons (exact like mock)
class _TwoCols extends StatelessWidget {
  const _TwoCols({
    required this.leftIcon,
    required this.leftText,
    required this.rightIcon,
    required this.rightText,
  });

  final IconData leftIcon;
  final String leftText;
  final IconData rightIcon;
  final String rightText;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: _mutedText, fontSize: 13.5, height: 1.25);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.attach_money_rounded, size: 18, color: _mutedText),
              const SizedBox(width: 6),
              Flexible(child: Text(leftText, style: labelStyle)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Icon(rightIcon, size: 18, color: _mutedText),
              const SizedBox(width: 6),
              Flexible(child: Text(rightText, style: labelStyle)),
            ],
          ),
        ),
      ],
    );
  }
}
