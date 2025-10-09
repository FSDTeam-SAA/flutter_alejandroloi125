// lib/feature/home/widgets/project_card.dart
import 'package:flutter/material.dart';

class ProjectMiniCard extends StatelessWidget {
  const ProjectMiniCard({
    super.key,
    required this.category,
    required this.title,
    required this.blurb,
    required this.priceRange,
    required this.duration,
    required this.location,
    required this.proposals,
    this.avatars = const [],
    this.onTap,
  });

  final String category;
  final String title;
  final String blurb;
  final String priceRange;
  final String duration;
  final String location;
  final String proposals;
  final List<String> avatars;
  final VoidCallback? onTap;

  static const _orange = Color(0xFFFF8C3B);

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0xFF2B2C31);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text(
              category,
              style: const TextStyle(
                color: _orange,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // Blurb
            Text(
              blurb,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),

            // Row 1: Budget + Days
            Row(
              children: [
                Expanded(
                  child: _MetaItem(
                    icon: Icons.attach_money_rounded,
                    text: priceRange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetaItem(
                    icon: Icons.timelapse_rounded,
                    text: duration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Location + Proposals
            Row(
              children: [
                Expanded(
                  child: _MetaItem(
                    icon: Icons.place_rounded,
                    text: location,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetaItem(
                    icon: Icons.group_rounded,
                    text: proposals,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: borderCol, height: 1),
            const SizedBox(height: 10),

            // Avatars + CTA
            Row(
              children: [
                _AvatarStack(urls: avatars),
                const Spacer(),
                const Text(
                  'View Details',
                  style: TextStyle(
                    color: _orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ),
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
      width: size +
          (urls.isEmpty ? 0 : (urls.length.clamp(0, 3) - 1) * overlap) +
          (extras > 0 ? overlap + 10 : 0),
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
