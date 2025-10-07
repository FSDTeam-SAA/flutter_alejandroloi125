// lib/feature/service/view/my_projects/my_project_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../providers/project_provider.dart';
import '../../../models/project.dart';
import 'my_project_details.dart';

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
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFFFF8A34),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                  // FIX 1: Don’t infer completed from days; only from API status
                  final apiStatus = (p.status ?? '').trim();
                  final completed =
                  apiStatus.toLowerCase().contains('complete');
                  final status =
                  apiStatus.isEmpty ? (completed ? 'Completed' : 'In Progress') : apiStatus;

                  // FIX 2: Days text is '-' if API doesn't send it
                  final int d = p.deadlineDays;
                  final daysText = d > 0 ? '$d Days' : '-';

                  final statusColor = completed
                      ? const Color(0xFF58D38C)
                      : const Color(0xFFFF8A34);

                  final proposalsText = '8 Proposals'; // placeholder

                  return _ProjectCard(
                    status: status,
                    statusColor: statusColor,
                    category: p.category,
                    title: p.title.isEmpty ? 'Untitled' : p.title,
                    description: p.description.isEmpty ? '—' : p.description,
                    budgetRange: _fmtBudget(p.minBudget, p.maxBudget),
                    days: daysText,
                    location: p.location.isEmpty ? '—' : p.location,
                    proposals: proposalsText,
                    completed: completed,
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete project?'),
                          content:
                          const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
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
    proposalsCount: 8,
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

// ======= Card (visuals aligned to your mock) =======

class _ProjectCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String category;
  final String title;
  final String description;
  final String budgetRange;
  final String days;
  final String location;
  final String proposals;
  final bool completed;

  final VoidCallback? onDelete;
  final VoidCallback onView;

  const _ProjectCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.category,
    required this.title,
    required this.description,
    required this.budgetRange,
    required this.days,
    required this.location,
    required this.proposals,
    required this.completed,
    this.onDelete,
    required this.onView,
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
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 6))
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoPill(icon: Icons.attach_money, text: budgetRange),
                    const SizedBox(width: 12),
                    _InfoPill(icon: Icons.schedule, text: days),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _InfoPill(icon: Icons.location_on_outlined, text: location),
                    const SizedBox(width: 12),
                    _InfoPill(icon: Icons.group_outlined, text: proposals),
                  ],
                ),
                const SizedBox(height: 14),

                if (!completed)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                            foregroundColor:
                            Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: onDelete,
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
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: onView,
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
                      onPressed: onView,
                      child: const Text('View Details'),
                    ),
                  ),
              ],
            ),
          ),

          // top-right status chip
          Positioned(
            top: 12,
            right: 12,
            left: 14,
            child: Row(
              children: [
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 38,
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
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
