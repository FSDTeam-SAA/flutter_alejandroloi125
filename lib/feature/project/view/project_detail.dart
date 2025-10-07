// lib/feature/project/view/project_detail.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'proposal.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.project, // if provided, we won't look anything up
  });

  /// Kept for backwards-compatibility with existing navigation.
  final String projectId;

  /// Optional prefilled data (preferred in a no-API setup).
  final ProjectDetailData? project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final ProjectDetailData _data;

  @override
  void initState() {
    super.initState();
    // No providers / APIs. Use the passed object if present,
    // otherwise look up from local sample data by id, else fall back to a stub.
    _data = widget.project ??
        kSampleProjectsDetail.firstWhere(
              (p) => p.id == widget.projectId,
          orElse: () => ProjectDetailData.stub(widget.projectId),
        );
  }

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
          secondary: Color(0xFF2A2B30), // chip/bg
        ),
        dividerColor: const Color(0xFF2B2C31),
        useMaterial3: true,
      ),
      home: _DetailBody(data: _data),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.data});
  final ProjectDetailData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final muted = Colors.white.withOpacity(.70);

    final postedOn = _fmtDate(data.createdAt ?? DateTime.now());
    final budgetRange = '\$ ${_fmt(data.budgetMin)} - ${_fmt(data.budgetMax)}';
    final daysText = '${data.durationDays} Days';
    final proposalsText = '${data.proposalsCount} Proposals';
    final location = data.location?.trim().isNotEmpty == true ? data.location! : '—';

    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // category pill
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.secondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(data.category, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),

            // title
            Text(data.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),

            // intro
            Text(
              data.shortIntro?.isNotEmpty == true
                  ? data.shortIntro!
                  : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra.',
              style: TextStyle(color: muted, height: 1.25),
            ),
            const SizedBox(height: 12),

            // posted on
            Row(
              children: [
                const Icon(Icons.event_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Posted on $postedOn',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // meta chips
            Row(
              children: [
                Expanded(child: _InfoChip(icon: Icons.attach_money_rounded, label: budgetRange)),
                const SizedBox(width: 18),
                Expanded(child: _InfoChip(icon: Icons.timelapse_rounded, label: daysText)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _InfoChip(icon: Icons.group_rounded, label: proposalsText)),
                const SizedBox(width: 18),
                Expanded(child: _InfoChip(icon: Icons.place_rounded, label: location)),
              ],
            ),

            const SizedBox(height: 16),

            // client
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 22, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.ownerName ?? 'Project Owner', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const _Stars(rating: 4.8),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '3 Projects • Success Rate 100%',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Posted on', style: TextStyle(color: muted, fontSize: 12)),
                    Text(postedOn, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (data.id.isNotEmpty) {
                    Get.to(
                          () => ProposalScreen(projectId: data.id),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Get.snackbar('Missing ID', 'Cannot submit proposal for this project');
                  }
                },
                child: const Text('Submit a Proposal', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 18),

            // description
            const _SectionHeader('Project Description'),
            const SizedBox(height: 8),
            _Para(
              data.description?.isNotEmpty == true
                  ? data.description!
                  : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis.',
            ),
            const _Para(
              'Blandit eget pretium finibus. Donec in malesuada fame ac sapien gravida imperdiet. In iaculis risus a feugiat convallis.',
            ),
            const SizedBox(height: 16),

            // skills
            const _SectionHeader('Skills Required'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (data.skills.isNotEmpty
                  ? data.skills
                  : const ['Web Design', 'Ecommerce', 'Shopify', 'WordPress', 'UI/UX'])
                  .map((s) => _Tag(s))
                  .toList(),
            ),
            const SizedBox(height: 18),

            // sample proposals (static to match design)
            const _SectionHeader('Project Proposal'),
            const SizedBox(height: 8),
            const ProposalCard(
              name: 'Eleanor Pena',
              avatarUrl: 'https://i.pravatar.cc/120?img=15',
              tagline: '2 Projects • Success Rate 100%',
              rating: 4.9,
              text:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra.',
              budget: '\$1200',
              delivery: '14 days',
            ),
            const SizedBox(height: 10),
            const ProposalCard(
              name: 'Eleanor Pena',
              avatarUrl: 'https://i.pravatar.cc/120?img=18',
              tagline: '3 Projects • Success Rate 100%',
              rating: 4.8,
              text:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra.',
              budget: '\$1200',
              delivery: '14 days',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Get.back(),
      ),
      title: const Text(''),
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(Icons.favorite_border_rounded),
        ),
      ],
    );
  }
}

// ---------- Local model (no API) ----------
class ProjectDetailData {
  final String id;
  final String category;
  final String title;
  final String? shortIntro;
  final String? description;
  final int budgetMin;
  final int budgetMax;
  final int durationDays;
  final String? location;
  final int proposalsCount;
  final String? ownerName;
  final DateTime? createdAt;
  final List<String> skills;

  const ProjectDetailData({
    required this.id,
    required this.category,
    required this.title,
    this.shortIntro,
    this.description,
    required this.budgetMin,
    required this.budgetMax,
    required this.durationDays,
    this.location,
    this.proposalsCount = 0,
    this.ownerName,
    this.createdAt,
    this.skills = const [],
  });

  factory ProjectDetailData.stub(String id) => ProjectDetailData(
    id: id,
    category: 'Design',
    title: 'Untitled Project',
    shortIntro:
    'Placeholder project used when no data was provided.',
    description:
    'This is a local-only view with no API integration. Provide ProjectDetailData to populate.',
    budgetMin: 0,
    budgetMax: 0,
    durationDays: 0,
    location: '—',
    proposalsCount: 0,
    ownerName: 'Project Owner',
    createdAt: DateTime.now(),
    skills: const ['UI/UX', 'Branding'],
  );
}

// --- sample local data to match list IDs (optional) ---
final kSampleProjectsDetail = <ProjectDetailData>[
  ProjectDetailData(
    id: 'p-101',
    category: 'Design',
    title: 'Minimal Landing Page for SaaS',
    shortIntro: 'A clean and responsive landing for a subscription product.',
    description:
    'We need a minimal, fast landing page with pricing, FAQs, and a contact form. Deliver responsive design and basic analytics.',
    budgetMin: 1500,
    budgetMax: 2500,
    durationDays: 12,
    location: 'Remote',
    proposalsCount: 8,
    ownerName: 'Eleanor Pena',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    skills: const ['UI/UX', 'Figma', 'Landing Pages', 'HTML/CSS'],
  ),
  ProjectDetailData(
    id: 'p-102',
    category: 'Mobile App',
    title: 'Flutter MVP for Fintech Wallet',
    shortIntro: 'Build an MVP with login, wallet, and simple transfers.',
    description:
    'MVP requires auth, wallet balance, P2P transfer mock, and transaction list. Clean architecture preferred.',
    budgetMin: 6000,
    budgetMax: 9000,
    durationDays: 28,
    location: 'Hybrid',
    proposalsCount: 15,
    ownerName: 'Courtney Henry',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    skills: const ['Flutter', 'Dart', 'REST', 'State Management'],
  ),
  ProjectDetailData(
    id: 'p-103',
    category: 'Web',
    title: 'Next.js E-commerce Prototype',
    shortIntro: 'Listing, cart, checkout with mock payments.',
    description:
    'Prototype with product listing, detail page, cart, and checkout flow. Stripe test mode acceptable.',
    budgetMin: 3500,
    budgetMax: 5500,
    durationDays: 20,
    location: 'On-site',
    proposalsCount: 5,
    ownerName: 'Ralph Edwards',
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
    skills: const ['Next.js', 'React', 'Tailwind', 'Stripe'],
  ),
];

// ---------- UI bits (unchanged visuals) ----------
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isTwoLine = label.contains('\n');
    final second = isTwoLine ? label.split('\n')[1] : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(
                width: 140,
                child: Text(
                  second,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
        Text(text, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
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
      child: Text(text, style: TextStyle(color: Colors.white.withOpacity(.75), height: 1.35)),
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
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

  final String name, avatarUrl, tagline, text, budget, delivery;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                const _Stars(rating: 4.8, compact: true),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tagline,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ]),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
            color: Colors.white70,
            padding: EdgeInsets.zero,
          ),
        ]),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.white70, height: 1.3)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(children: [
            Expanded(child: _kv('Budget', budget)),
            const SizedBox(width: 12),
            Expanded(child: _kv('Delivery Time', delivery, alignEnd: true)),
          ]),
        ),
      ]),
    );
  }

  Widget _kv(String k, String v, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
        Text(rating.toStringAsFixed(1),
            style: TextStyle(fontSize: compact ? 12 : 14, color: Colors.white70)),
      ],
    );
  }
}

// ---- helpers ----
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

String _fmtDate(DateTime d) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${months[d.month]} ${d.day}, ${d.year}';
}
