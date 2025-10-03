// lib/feature/project/view/project.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../app_ground.dart';
import '../../create_service/provider/project_provider.dart';
import 'project_detail.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projects',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8C3B), // accent (orange)
          secondary: Color(0xFF2A2B30),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFECECEC),
          displayColor: const Color(0xFFECECEC),
        ),
        dividerColor: const Color(0xFF2B2C31),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F10),
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: const ProjectsPage(),
    );
  }
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  // fallback avatars when API has none
  static const _dummyAvatars = <String>[
    'https://i.pravatar.cc/100?img=3',
    'https://i.pravatar.cc/100?img=5',
    'https://i.pravatar.cc/100?img=8',
    'https://i.pravatar.cc/100?img=10',
    'https://i.pravatar.cc/100?img=12',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProjectProvider>().fetchAllProjects());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProjectProvider>();

    // Adapt provider items to this UI's Project class (design untouched)
    final List<Project> projects = p.projects.map((raw) {
      String id = '';
      String category = 'Design';
      String title = 'Untitled';
      String description = '';
      String budget = '\$ 0 - 0';
      int days = 0;
      String location = '';
      int proposals = 0;
      List<String> memberImages = const [];

      // safe mapping (works even if some fields are missing)
      try {
        final v = (raw as dynamic).id;
        if (v is String) id = v;
      } catch (_) {}
      try {
        final v = (raw as dynamic)._id;
        if (v is String) id = v;
      } catch (_) {}

      try {
        final v = (raw as dynamic).category;
        if (v is String) category = v;
      } catch (_) {}
      try {
        final v = (raw as dynamic).name;
        if (v is String && v.isNotEmpty) title = v;
      } catch (_) {}
      try {
        final v = (raw as dynamic).title;
        if (v is String && v.isNotEmpty) title = v;
      } catch (_) {}
      try {
        final v = (raw as dynamic).description;
        if (v is String) description = v;
      } catch (_) {}

      int? bmin;
      int? bmax;
      try {
        final v = (raw as dynamic).budgetMin;
        if (v is num) bmin = v.toInt();
      } catch (_) {}
      try {
        final v = (raw as dynamic).budget_min;
        if (v is num) bmin = v.toInt();
      } catch (_) {}
      try {
        final v = (raw as dynamic).budgetMax;
        if (v is num) bmax = v.toInt();
      } catch (_) {}
      try {
        final v = (raw as dynamic).budget_max;
        if (v is num) bmax = v.toInt();
      } catch (_) {}
      if (bmin != null || bmax != null) {
        budget = '\$ ${_fmt(bmin ?? 0)} - ${_fmt(bmax ?? 0)}';
      }

      try {
        final v = (raw as dynamic).duration;
        if (v is String) {
          final n = int.tryParse(RegExp(r'\d+').firstMatch(v)?.group(0) ?? '');
          if (n != null) days = n;
        }
      } catch (_) {}
      try {
        final v = (raw as dynamic).durationDays;
        if (v is num) days = v.toInt();
      } catch (_) {}

      try {
        final v = (raw as dynamic).location;
        if (v is String) location = v;
      } catch (_) {}
      try {
        final v = (raw as dynamic).proposalsCount;
        if (v is num) proposals = v.toInt();
      } catch (_) {}

      try {
        final imgs = (raw as dynamic).memberImages;
        if (imgs is List) memberImages = imgs.whereType<String>().toList();
      } catch (_) {}

      // ✅ always keep dummy avatars if API provides none
      if (memberImages.isEmpty) {
        memberImages = _dummyAvatars;
      }

      return Project(
        id: id,
        category: category,
        title: title,
        description: description,
        budget: budget,
        days: days,
        location: location,
        proposals: proposals,
        memberImages: memberImages,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.offAll(
                () => const AppGround(), // or AppGround(initialIndex: 0)
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Project'),
        actions: const [SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const _SearchBar(),
            const SizedBox(height: 12),

            if (p.loadingList) ...[
              const _SkeletonCard(),
              const SizedBox(height: 12),
              const _SkeletonCard(),
              const SizedBox(height: 12),
              const _SkeletonCard(),
            ] else if ((p.error ?? '').isNotEmpty) ...[
              _ErrorBox(
                message: p.error!,
                onRetry: () => context.read<ProjectProvider>().fetchAllProjects(),
              ),
            ] else if (projects.isEmpty) ...[
              const _EmptyState(),
            ] else ...[
              for (final proj in projects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCard(
                    project: proj,
                    onViewDetails: () {
                      if (proj.id?.isNotEmpty == true) {
                        Get.to(
                              () => ProjectDetailScreen(projectId: proj.id!),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Get.snackbar('Missing ID', 'Cannot open details for this project');
                      }
                    },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Search bar (unchanged visually)
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.search_rounded),
                const SizedBox(width: 8),
                const Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search Project',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter',
          ),
        ),
      ],
    );
  }
}

// ---- Project card (pixel-matched + avatar chip)
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onViewDetails,
  });

  final Project project;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C3B);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          Text(
            project.category,
            style: const TextStyle(
              color: orange,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            project.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),

          // Row 1
          _TwoCols(
            leftIcon: Icons.attach_money_rounded,
            leftText: project.budget,
            rightIcon: Icons.timelapse_rounded,
            rightText: '${project.days} Days',
          ),
          const SizedBox(height: 8),

          // Row 2
          _TwoCols(
            leftIcon: Icons.place_rounded,
            leftText: project.location,
            rightIcon: Icons.group_rounded,
            rightText: '${project.proposals} Proposals',
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2B2C31), height: 1, thickness: 1),
          const SizedBox(height: 10),

          // Avatars in dark pill + "View Details"
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _StackedAvatars(urls: project.memberImages),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onViewDetails,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    const labelStyle = TextStyle(
      color: Colors.white70,
      fontSize: 13.5,
      height: 1.0,
    );

    Widget chip(IconData i, String t) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(i, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            t,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Row(
      children: [
        Expanded(child: chip(leftIcon, leftText)),
        const SizedBox(width: 12),
        Expanded(child: chip(rightIcon, rightText)),
      ],
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    const double size = 24; // avatar diameter
    const double overlap = 12;

    final visible = urls.take(4).toList();
    final extra = urls.length > 4 ? urls.length - 4 : 0;

    // width for the stack including "+n" bubble
    final baseWidth = visible.isEmpty ? 0.0 : size + (visible.length - 1) * overlap;
    final totalWidth = baseWidth + (extra > 0 ? size : 0);

    return SizedBox(
      height: size,
      width: totalWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.black, // thin ring
                child: CircleAvatar(
                  radius: size / 2 - 1.2,
                  backgroundImage: NetworkImage(visible[i]),
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: baseWidth,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 1.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- skeleton / error / empty states
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Couldn’t load projects', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onRetry, child: const Text('Retry')),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(Icons.topic_outlined, size: 32, color: Colors.white.withOpacity(.65)),
        const SizedBox(height: 8),
        Text('No projects found', style: TextStyle(color: Colors.white.withOpacity(.8))),
      ],
    );
  }
}

// --- UI data class (unchanged design; optional id for routing)
class Project {
  final String? id;
  final String category;
  final String title;
  final String description;
  final String budget;
  final int days;
  final String location;
  final int proposals;
  final List<String> memberImages;

  const Project({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.budget,
    required this.days,
    required this.location,
    required this.proposals,
    required this.memberImages,
  });
}

String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) buf.write(',');
  }
  return buf.toString();
}
