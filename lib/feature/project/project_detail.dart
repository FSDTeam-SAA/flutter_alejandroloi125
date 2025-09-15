import 'package:alejandroloi/feature/project/proposal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(const ProjectDetailScreen());

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Detail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8C3B), // accent orange
          secondary: Color(0xFF2A2B30),
        ),
        dividerColor: const Color(0xFF2B2C31),
        useMaterial3: true,
      ),
      home: const ProjectDetailPage(),
    );
  }
}

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = Colors.white.withOpacity(0.70);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {},
        ),
        title: const Text(''),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Category
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.secondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  'Design',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Title
            const Text(
              'Website Redesign for Local Business',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            // Short intro
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio eu venenatis efficitur.',
              style: TextStyle(color: muted, height: 1.25),
            ),
            const SizedBox(height: 14),
            // Meta row 1
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: const [
                _InfoChip(icon: Icons.event_rounded, label: 'Posted on\nJune 1, 2023'),
                _InfoChip(icon: Icons.attach_money_rounded, label: '\$ 1,500 - 3,000'),
                _InfoChip(icon: Icons.timelapse_rounded, label: '15 Days'),
                _InfoChip(icon: Icons.place_rounded, label: 'Brooklyn, NY'),
                _InfoChip(icon: Icons.group_rounded, label: '8 Proposals'),
              ],
            ),
            const SizedBox(height: 16),
            // Client / Poster
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Eleanor Pena',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _Stars(rating: 4.8),
                          const SizedBox(width: 8),
                          Text('Top Rated 100%',
                              style:
                              TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Posted on', style: TextStyle(color: muted, fontSize: 12)),
                    const Text('June 1, 2025',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Get.to(ProposalScreen());
                },
                child: const Text(
                  'Submit a Proposal',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Description
            const _SectionHeader('Project Description'),
            const SizedBox(height: 8),
            const _Para(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis. Curabitur sodales metus et congue porttitor.'),
            const _Para(
                'Blandit eget pretium finibus. Donec in malesuada fame ac sapien gravida imperdiet. In iaculis, risus a feugiat convallis dapibus, lacus sapien sem, vehicula in lorem non, blandit volutpat sapien. Aenean in posuere massa. Nunc malesuada sem in rutrum posuere. Quisque a auctor nibh.'),
            const _Para(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sapien nulla, ultrices a ligula interdum, tempus rutrum libero. Nam tempus erat vel dui tincidunt vulputate. Aliquam elementum, quam a placerat accumsan, augue orci pharetra justo, at pretium magna augue nec lacus.'),
            const SizedBox(height: 16),
            // Skills
            const _SectionHeader('Skills Required'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _Tag('Web Design'),
                _Tag('Ecommerce'),
                _Tag('Shopify'),
                _Tag('WordPress'),
                _Tag('UI/UX'),
              ],
            ),
            const SizedBox(height: 18),
            // Proposals
            const _SectionHeader('Project Proposal'),
            const SizedBox(height: 8),
            const ProposalCard(
              name: 'Eleanor Pena',
              avatarUrl: 'https://i.pravatar.cc/120?img=15',
              tagline: 'Designer · Senior · 5+ yrs',
              rating: 4.9,
              text:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio eu venenatis efficitur.',
              budget: '\$1200',
              delivery: '14 days',
            ),
            const SizedBox(height: 10),
            const ProposalCard(
              name: 'Eleanor Pena',
              avatarUrl: 'https://i.pravatar.cc/120?img=18',
              tagline: 'Designer · Senior · 5+ yrs',
              rating: 4.8,
              text:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio eu venenatis efficitur.',
              budget: '\$1200',
              delivery: '14 days',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------- UI Bits ----------

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isTwoLine = label.contains('\n');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTwoLine)
                Text(
                  label.split('\n')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              Text(
                isTwoLine ? label.split('\n')[1] : label,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _Para extends StatelessWidget {
  const _Para(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.75), height: 1.35),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
      ),
    );
  }
}

class ProposalCard extends StatelessWidget {
  const ProposalCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.tagline,
    required this.rating,
    required this.text,
    required this.budget,
    required this.delivery,
  });

  final String name;
  final String avatarUrl;
  final String tagline;
  final double rating;
  final String text;
  final String budget;
  final String delivery;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(tagline,
                            style:
                            const TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(width: 8),
                        _Stars(rating: rating, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded),
                color: Colors.white70,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text,
              style: const TextStyle(color: Colors.white70, height: 1.3)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _kv('Budget', budget),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kv('Delivery Time', delivery, alignEnd: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.compact = false});
  final double rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final icon = i < full
              ? Icons.star_rounded
              : (i == full && half ? Icons.star_half_rounded : Icons.star_border_rounded);
          return Icon(icon, size: compact ? 14 : 18, color: const Color(0xFFFFC107));
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
