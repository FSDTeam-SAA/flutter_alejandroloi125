import 'package:alejandroloi/feature/service/view/my_projects/my_project_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:provider/provider.dart';

// adjust path to your provider file
import '../../../create_service/provider/project_provider.dart';

class MyProjectScreen extends StatelessWidget {
  const MyProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<ProjectProvider>().fetchAllProjects(),
          child: Consumer<ProjectProvider>(
            builder: (context, p, _) {
              // Trigger initial load once, safely from build:
              if (!p.loadingList && p.projects.isEmpty && p.error == null) {
                // will be ignored on subsequent rebuilds because loadingList flips true
                Future.microtask(() => p.fetchAllProjects());
              }

              // loading first paint
              if (p.loadingList && p.projects.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // error & empty
              if (p.error != null && p.projects.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      p.error!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => p.fetchAllProjects(),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              // empty state
              if (p.projects.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 40),
                    Icon(Icons.inbox_outlined, color: Colors.white54, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No projects yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                );
              }

              // list
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: p.projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final item = p.projects[i];

                  final status = item.status ??
                      ((item.durationDays != null && (item.durationDays ?? 0) <= 0)
                          ? 'Completed'
                          : 'In Progress');

                  final statusColor = status.toLowerCase().contains('complete')
                      ? const Color(0xFF58D38C)
                      : const Color(0xFFFF8A34);

                  final deleting = p.deletingIds.contains(item.id);

                  return _ProjectCard(
                    status: status,
                    statusColor: statusColor,
                    category: item.category,
                    title: item.title,
                    description: item.description,
                    budgetRange: _fmtBudget(item.budgetMin, item.budgetMax),
                    days: item.durationDays != null ? '${item.durationDays} Days' : '-',
                    location: item.location,
                    proposals: '${item.proposalsCount ?? 0} Proposals',
                    completed: status.toLowerCase().contains('complete'),
                    onDelete: deleting
                        ? null
                        : () async {
                      final ok = await context.read<ProjectProvider>().deleteProject(item.id);
                      if (!ok && context.mounted && p.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(p.error!)),
                        );
                      }
                    },
                    onView: () {
                      // pass id if your details screen expects it
                      Get.to(
                            () => MyProjectDetailScreen( projectId: item.id ),
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

  String _fmtBudget(int? min, int? max) {
    if (min == null && max == null) return '-';
    if (min != null && max != null) return '\$ ${_sep(min)} - ${_sep(max)}';
    if (min != null) return '\$ ${_sep(min)}+';
    return '\$ ${_sep(max!)}';
  }

  String _sep(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final left = s.length - i - 1;
      if (left % 3 == 0 && left != 0) buf.write(',');
    }
    return buf.toString();
  }
}

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
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
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
                            side: BorderSide(color: Colors.white.withOpacity(0.15)),
                            foregroundColor: Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Positioned(
            top: 12,
            right: 12,
            left: 14,
            child: Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
