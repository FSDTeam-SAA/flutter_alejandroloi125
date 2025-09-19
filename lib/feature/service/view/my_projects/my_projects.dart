import 'package:alejandroloi/feature/service/view/my_projects/my_project_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyProjectScreen extends StatelessWidget {
  const MyProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            _ProjectCard(
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              category: 'Design',
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$ 1,500 - 3,000',
              days: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              completed: false,
            ),
            SizedBox(height: 14),
            _ProjectCard(
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              category: 'Design',
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$ 1,500 - 3,000',
              days: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              completed: false,
            ),
            SizedBox(height: 14),
            _ProjectCard(
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              category: 'Design',
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$ 1,500 - 3,000',
              days: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              completed: false,
            ),
            SizedBox(height: 14),
            _ProjectCard(
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              category: 'Design',
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$ 1,500 - 3,000',
              days: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              completed: false,
            ),
            SizedBox(height: 14),
            _ProjectCard(
              status: 'Completed',
              statusColor: Color(0xFF58D38C),
              category: 'Design',
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$ 1,500 - 3,000',
              days: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              completed: true,
            ),
          ],
        ),
      ),
    );
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

  const _ProjectCard({
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
                // Category + badge spacer
                SizedBox(height: 4 + 24), // space under badge row height
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
                // Info rows
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
                // Buttons
                // Buttons
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
                          onPressed: () {
                            // your delete logic here
                          },
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
                          onPressed: () {
                            Get.to(
                                  () => const MyProjectDetailScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
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
                      onPressed: () {
                        Get.to(
                              () => const MyProjectDetailScreen(),
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
          ),

          // Top row with badge
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
