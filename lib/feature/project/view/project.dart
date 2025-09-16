import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'project_detail.dart';

void main() => runApp(const ProjectScreen());

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

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = List<Project>.generate(
      5,
          (i) => Project(
        category: 'Design',
        title: 'Website Redesign for Local Business',
        description:
        'Looking for an experienced web designer to revamp our company website. Need',
        budget: '\$ 1,500 - 3,000',
        days: 15,
        location: 'Brooklyn, NY',
        proposals: 8,
        memberImages: const [
          'https://i.pravatar.cc/150?img=3',
          'https://i.pravatar.cc/150?img=5',
          'https://i.pravatar.cc/150?img=8',
          'https://i.pravatar.cc/150?img=10',
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Project'),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const _SearchBar(),
            const SizedBox(height: 12),
            ...projects.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProjectCard(project: p),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

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
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
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

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = Colors.white.withOpacity(0.65);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    project.category,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            // Description (1–2 lines)
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: muted,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            // Info rows (budget / days / location / proposals)
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.attach_money_rounded,
                  label: project.budget,
                ),
                _InfoChip(
                  icon: Icons.timelapse_rounded,
                  label: '${project.days} Days',
                ),
                _InfoChip(
                  icon: Icons.place_rounded,
                  label: project.location,
                ),
                _InfoChip(
                  icon: Icons.group_rounded,
                  label: '${project.proposals} Proposals',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Avatars + CTA
            Row(
              children: [
                _StackedAvatars(urls: project.memberImages),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Get.to(ProjectDetailScreen());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double overlap = 12;

    return SizedBox(
      height: size,
      width: size + (urls.length - 1) * overlap + 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < urls.length && i < 4; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: size / 2 - 1.5,
                  backgroundImage: NetworkImage(urls[i]),
                ),
              ),
            ),
          if (urls.length > 3)
            Positioned(
              left: 3 * overlap + 2,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B30),
                  border: Border.all(color: Colors.black, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '+${urls.length - 3}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Project {
  final String category;
  final String title;
  final String description;
  final String budget;
  final int days;
  final String location;
  final int proposals;
  final List<String> memberImages;

  const Project({
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
