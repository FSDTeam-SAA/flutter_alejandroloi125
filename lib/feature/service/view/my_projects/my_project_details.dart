// lib/feature/service/view/my_projects/my_project_details.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../create_service/provider/project_provider.dart';

class MyProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const MyProjectDetailScreen({super.key, required this.projectId});

  @override
  State<MyProjectDetailScreen> createState() => _MyProjectDetailScreenState();
}

class _MyProjectDetailScreenState extends State<MyProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<ProjectProvider>().fetchProjectById(widget.projectId),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0F12);
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Consumer<ProjectProvider>(
            builder: (context, p, _) {
              if (!p.loadingOne &&
                  (p.currentProject == null ||
                      p.currentProject!.id != widget.projectId) &&
                  p.error == null) {
                Future.microtask(
                      () => p.fetchProjectById(widget.projectId),
                );
              }

              if (p.loadingOne && p.currentProject == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (p.error != null && p.currentProject == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              p.fetchProjectById(widget.projectId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final pr = p.currentProject!;
              final title = pr.title;
              final category = pr.category;
              final description = pr.description;
              final budget = _fmtBudget(pr.budgetMin, pr.budgetMax);
              final days = pr.durationDays != null
                  ? '${pr.durationDays} Days'
                  : '-';
              final location = pr.location.isEmpty ? '-' : pr.location;
              final proposals = '${pr.proposalsCount ?? 0} Proposals';
              final created = _fmtDate(pr.createdAt);
              final due = _fmtDate(_dueDate(pr.createdAt, pr.durationDays));

              return RefreshIndicator(
                onRefresh: () => p.fetchProjectById(widget.projectId),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    // Main card
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row (back + actions)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Row(
                              children: [
                                _CircleIconButton(
                                  icon: Icons.arrow_back_ios_new,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const Spacer(),
                                _CircleIconButton(
                                  icon: Icons.favorite_border,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 8),
                                _CircleIconButton(
                                  icon: Icons.more_horiz,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Title block
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Badge(
                                  text: category.isEmpty ? '-' : category,
                                  color: accent,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title.isEmpty
                                      ? '(Untitled Project)'
                                      : title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description.isEmpty
                                      ? 'No description provided.'
                                      : description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),

                          // Stats rows (as per figma)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              children: [
                                _StatRow(
                                  leadingLabel: 'Posted on',
                                  leadingValue: created,
                                  // Figma shows "Posted on" on the right as well
                                  trailingLabel: 'Posted on',
                                  trailingValue: due == '-' ? created : due,
                                ),
                                const SizedBox(height: 12),
                                _IconRow(
                                  items: [
                                    _IconRowItem(
                                      icon: Icons.attach_money,
                                      label: budget,
                                    ),
                                    _IconRowItem(
                                      icon: Icons.schedule,
                                      label: days,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _IconRow(
                                  items: [
                                    _IconRowItem(
                                      icon: Icons.location_on_outlined,
                                      label: location,
                                    ),
                                    _IconRowItem(
                                      icon: Icons.group_outlined,
                                      label: proposals,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Client line (Figma)
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(14, 14, 14, 0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(
                                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // pr.clientName ?? 'Client',
                                      'El',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      // '${(pr.clientStats ?? '3 Projects')} · ${(pr.clientSuccessRate ?? 'Success Rate 100%')}',
                                      'Success Rate 100%',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Posted on',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      created,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Project Description (Figma label)
                          const _SectionHeader('Project Description'),
                          if (description.isNotEmpty)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                              child: _Para(description),
                            )
                          else
                            const Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 14),
                              child: _Para('No description provided.'),
                            ),
                          const SizedBox(height: 12),

                          // Skills Required (chips)
                          const _SectionHeader('Skills Required'),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (pr.skills.isEmpty
                                  ? const ['-']
                                  : pr.skills)
                                  .map((s) => _SkillChip(s))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Project Proposal (Figma cards) – placeholders unless you have real data list
                          const _SectionHeader('Project Proposal'),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: _ProposalCard(
                              name: 'Eleanor Pena',
                              summary:
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                                  'Nunc interdum metus eu egestas pharetra. Fusce bibendum odio '
                                  'et venenatis efficitur.',
                              budgetText: '\$1200',
                              deliveryText: '14 days',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: _ProposalCard(
                              name: 'Eleanor Pena',
                              summary:
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                                  'Nunc interdum metus eu egestas pharetra.',
                              budgetText: '\$1200',
                              deliveryText: '14 days',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ====== Helpers & UI atoms ======

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

String _fmtDate(DateTime? d) {
  if (d == null) return '-';
  const m = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  final dt = d.toLocal();
  return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
}

DateTime? _dueDate(DateTime? start, int? days) {
  if (start == null || days == null) return null;
  return start.add(Duration(days: days));
}

// ——— atoms

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String leadingLabel, leadingValue;
  final String trailingLabel, trailingValue;
  const _StatRow({
    required this.leadingLabel,
    required this.leadingValue,
    required this.trailingLabel,
    required this.trailingValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LabeledText(label: leadingLabel, value: leadingValue),
        const Spacer(),
        _LabeledText(label: trailingLabel, value: trailingValue, alignEnd: true),
      ],
    );
  }
}

class _LabeledText extends StatelessWidget {
  final String label, value;
  final bool alignEnd;
  const _LabeledText({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _IconRowItem {
  final IconData icon;
  final String label;
  const _IconRowItem({required this.icon, required this.label});
}

class _IconRow extends StatelessWidget {
  final List<_IconRowItem> items;
  const _IconRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final e = items[i];
      children.add(
        Expanded(
          child: Container(
            height: 40,
            margin: EdgeInsets.only(right: i == items.length - 1 ? 0 : 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F26),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A313A)),
            ),
            child: Row(
              children: [
                Icon(e.icon, size: 16, color: Colors.white.withOpacity(0.85)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    e.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Row(children: children);
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

class _Para extends StatelessWidget {
  final String text;
  const _Para(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.78), height: 1.45),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2A313A)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Figma-like proposal card (static UI; bind to real data when available)
class _ProposalCard extends StatelessWidget {
  final String name;
  final String summary;
  final String budgetText;
  final String deliveryText;

  const _ProposalCard({
    required this.name,
    required this.summary,
    required this.budgetText,
    required this.deliveryText,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF8A34);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2A313A)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (avatar + name + stats)
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1527980965255-d3b416303d12',
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(
                    '3 Projects · Success Rate 100%',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Para(summary),
          const SizedBox(height: 12),
          // Budget / Delivery aligned row
          Row(
            children: [
              const _LabeledText(label: 'Budget', value: ''),
              Text(budgetText,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              const _LabeledText(
                  label: 'Delivery Time', value: '', alignEnd: true),
              Text(deliveryText,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    foregroundColor: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text('Rejection'),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text('Accepted'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
