// lib/feature/project/view/project_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_service/api_client.dart';
import '../../../core/network/api_service/token_store.dart';
import '../controller/project_controller.dart';

import '../model/project_model.dart';
import '../repo/project_repo.dart';
import '../services/project_services.dart';
import 'project_detail.dart';
import '../../app_ground.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _searchCtl = TextEditingController();
  late final ProjectController controller;

  @override
  void initState() {
    super.initState();

    // ✅ Setup dependencies
    final tokenStore = TokenStore();
    final apiClient = ApiClient(tokenStore);
    final service = ProjectService(apiClient);
    final repo = ProjectRepository(service);
    controller = Get.put(ProjectController(repo));

    // ✅ Load initial projects
    controller.loadProjects();
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,),
          onPressed: () => Get.offAll(
                () => const AppGround(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 350),
          ),
        ),
        title: const Text('Projects',style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // 🔹 Search bar
              _SearchBar(
                controller: _searchCtl,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // 🔹 Reactive project list
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  final q = _searchCtl.text.trim().toLowerCase();
                  final filtered = controller.projects.where((p) {
                    if (q.isEmpty) return true;
                    return p.title.toLowerCase().contains(q) ||
                        p.location.toLowerCase().contains(q) ||
                        p.category.toLowerCase().contains(q);
                  }).toList();

                  if (filtered.isEmpty) return const _EmptyState();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final proj = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectCard(
                          project: proj,
                          onViewDetails: () {
                            if ((proj.id ?? '').isNotEmpty) {
                              Get.to(
                                    () => ProjectDetailScreen(projectId: proj.id!),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            } else {
                              Get.snackbar(
                                'Missing ID',
                                'Cannot open details for this project',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Search bar widget
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search Project',
                      border: InputBorder.none,
                      isDense: true,
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: const Icon(Icons.cancel_outlined, size: 18, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.secondaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            tooltip: 'Filter',
          ),
        ),
      ],
    );
  }
}

// 🔹 Project card widget
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onViewDetails});

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
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.category, style: const TextStyle(color: orange, fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(project.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text(project.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          const SizedBox(height: 12),
          _TwoCols(
            leftIcon: Icons.attach_money_rounded,
            leftText: project.budget,
            rightIcon: Icons.timelapse_rounded,
            rightText: '${project.days} Days',
          ),
          const SizedBox(height: 8),
          _TwoCols(
            leftIcon: Icons.place_rounded,
            leftText: project.location,
            rightIcon: Icons.group_rounded,
            rightText: '${project.proposals} Proposals',
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2B2C31), height: 1),
          const SizedBox(height: 10),
          Row(
            children: [ _AvatarStack(urls: []),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onViewDetails,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text('View Details', style: TextStyle(color: orange, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




// 🔹 Two-column helper
class _TwoCols extends StatelessWidget {
  const _TwoCols({required this.leftIcon, required this.leftText, required this.rightIcon, required this.rightText});

  final IconData leftIcon;
  final String leftText;
  final IconData rightIcon;
  final String rightText;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: Colors.white70, fontSize: 13.5);
    return Row(
      children: [
        Expanded(child: Row(children: [Icon(leftIcon, size: 18, color: Colors.white70), const SizedBox(width: 6), Text(leftText, style: labelStyle)])),
        const SizedBox(width: 12),
        Expanded(child: Row(children: [Icon(rightIcon, size: 18, color: Colors.white70), const SizedBox(width: 6), Text(rightText, style: labelStyle)])),
      ],
    );
  }
}

// 🔹 Empty state
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


class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double overlap = 12;
    final extras = urls.length > 3 ? urls.length - 3 : 0;

    return SizedBox(
      height: size,
      width: size + (urls.isEmpty ? 0 : (urls.length.clamp(0, 3) - 1) * overlap) + (extras > 0 ? overlap + 10 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < urls.length && i < 3; i++)
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
          if (extras > 0)
            Positioned(
              left: 3 * overlap,
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
                  '+$extras',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
