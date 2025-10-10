// lib/feature/project/view/project_detail.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_service/api_client.dart';
import '../../../core/network/api_service/token_store.dart';

import '../../../providers/project_provider.dart';
import '../../../repository/project_repository.dart';
import '../../../services/project_service.dart';
import '../../models/project.dart';
import 'proposal.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.prefetched,
  });

  final String projectId;
  final Project? prefetched;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectProvider>(
      create: (_) {
        final tokenStore = TokenStore();
        final apiClient  = ApiClient(tokenStore);
        final service    = ProjectService(apiClient);
        final repo       = ProjectRepository(service);
        return ProjectProvider(repo); // no fetch here
      },
      child: _DetailBody(projectId: projectId, prefetched: prefetched),
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({required this.projectId, this.prefetched});
  final String projectId;
  final Project? prefetched;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  Project? _proj;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer the first load to after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (widget.prefetched != null) {
      if (!mounted) return;
      setState(() {
        _proj = widget.prefetched;
        _loading = false;
        _error = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final p = await context.read<ProjectProvider>().getById(widget.projectId);
      if (!mounted) return;
      setState(() {
        _proj = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F0F10),
      cardColor: const Color(0xFF1A1B1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF8C3B),
        secondary: Color(0xFF2A2B30),
      ),
      dividerColor: const Color(0xFF2B2C31),
    );

    if (_loading) {
      return Theme(
        data: theme,
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8C3B)),
          ),
        ),
      );
    }
    if (_error != null) {
      return Theme(
        data: theme,
        child: Scaffold(
          appBar: _appBar(context),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Couldn’t load project details',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(onPressed: _load, child: const Text('Retry')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data   = _proj!;
    final cs     = theme.colorScheme;
    final muted  = Colors.white.withOpacity(.70);
    final posted = _fmtDate(DateTime.now()); // no createdAt in model

    final budgetRange  = _fmtBudget(data.minBudget, data.maxBudget);
    final daysText     = data.deadlineDays > 0 ? '${data.deadlineDays} Days' : '-';
    final proposalsTxt = '${data.skills.length} Proposals'; // placeholder
    final location     = data.location.trim().isNotEmpty ? data.location : '—';
    final skills       = data.skills.isNotEmpty
        ? data.skills
        : const ['Web Design', 'Ecommerce', 'Shopify', 'WordPress', 'UI/UX'];

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: _appBar(context),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(
                    data.category.isNotEmpty ? data.category : '—',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                data.title.isNotEmpty ? data.title : 'Untitled Project',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),

              Text(
                data.description.isNotEmpty
                    ? data.description
                    : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra.',
                style: TextStyle(color: muted, height: 1.25),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.event_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posted on $posted',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                  Expanded(child: _InfoChip(icon: Icons.group_rounded, label: proposalsTxt)),
                  const SizedBox(width: 18),
                  Expanded(child: _InfoChip(icon: Icons.place_rounded, label: location)),
                ],
              ),

              const SizedBox(height: 16),

              Row(
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
                        const Text('Project Owner', style: TextStyle(fontWeight: FontWeight.w700)),
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
                      Text(posted, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                  child: const Text('Submit a Proposal',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 18),

              const SectionHeader(text: 'Project Description'),
              const SizedBox(height: 8),
              _Para(
                data.description.isNotEmpty
                    ? data.description
                    : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis.',
              ),
              const _Para(
                'Blandit eget pretium finibus. Donec in malesuada fame ac sapien gravida imperdiet. In iaculis risus a feugiat convallis.',
              ),
              const SizedBox(height: 16),

              const SectionHeader(text: 'Skills Required',),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) => _Tag(s)).toList(),
              ),
              const SizedBox(height: 18),

              const SectionHeader(text: 'Project Proposal'),
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
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) => AppBar(
    backgroundColor: const Color(0xFF0F0F10),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => Get.back(),
    ),
    title: const Text('', style: TextStyle(color: Colors.white)),
    centerTitle: false,
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 6),
        child: Icon(Icons.favorite_border_rounded),
      ),
    ],
  );
}

// ---------- UI bits & helpers ----------

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
      decoration:
      BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTwoLine)
                Text(label.split('\n')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              SizedBox(
                width: 140,
                child: Text(second,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key,  required this.text, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(text, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
      const Spacer(),
      if (trailing != null) trailing!,
    ],
  );
}

class _Para extends StatelessWidget {
  const _Para(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text,
        style: TextStyle(color: Colors.white.withOpacity(.75), height: 1.35)),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF2A2B30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF2B2C31)),
    ),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
  );
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1B1E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF2B2C31)),
    ),
    padding: const EdgeInsets.all(12),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(children: [
                  const _Stars(rating: 4.8, compact: true),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(tagline,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                        overflow: TextOverflow.ellipsis),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2B30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2B2C31)),
        ),
        child: Row(children: [
          Expanded(child: _kv('Budget', budget)),
          const SizedBox(width: 12),
          Expanded(child: _kv('Delivery Time', delivery, alignEnd: true)),
        ]),
      ),
    ]),
  );

  static Widget _kv(String k, String v, {bool alignEnd = false}) => Column(
    crossAxisAlignment:
    alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 0),
      Text(k, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      const SizedBox(height: 2),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
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
              : (i == full && half
              ? Icons.star_half_rounded
              : Icons.star_border_rounded);
          return Icon(icon,
              size: compact ? 14 : 18, color: const Color(0xFFFFC107));
        }),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(
                fontSize: compact ? 12 : 14, color: Colors.white70)),
      ],
    );
  }
}

// ---- helpers ----
String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final left = s.length - i - 1;
    buf.write(s[i]);
    if (left % 3 == 0 && left != 0) buf.write(',');
  }
  return buf.toString();
}

String _fmtBudget(int min, int max) {
  if (min == 0 && max == 0) return '-';
  if (min > 0 && max > 0) return '\$ ${_fmt(min)} - \$ ${_fmt(max)}';
  if (min > 0) return '\$ ${_fmt(min)}+';
  return '\$ ${_fmt(max)}';
}

String _fmtDate(DateTime d) {
  const m = [
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
  return '${m[d.month]} ${d.day}, ${d.year}';
}
