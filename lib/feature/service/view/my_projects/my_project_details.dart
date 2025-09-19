import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyProjectDetailScreen extends StatelessWidget {
  const MyProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0F12);
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
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
                    BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
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
                          _CircleIconButton(icon: Icons.favorite_border, onTap: () {}),
                          const SizedBox(width: 8),
                          _CircleIconButton(icon: Icons.more_horiz, onTap: () {}),
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
                          const _Badge(text: 'Design', color: accent),
                          const SizedBox(height: 8),
                          const Text(
                            'Website Redesign for Local Business',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), height: 1.35),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Stats rows
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: const [
                          _StatRow(
                            leadingLabel: 'Posted on',
                            leadingValue: 'June 1, 2023',
                            trailingLabel: 'Posted on',
                            trailingValue: 'June 1, 2025',
                          ),
                          SizedBox(height: 12),
                          _IconRow(
                            items: [
                              _IconRowItem(icon: Icons.location_on_outlined, label: 'Brooklyn, NY'),
                              _IconRowItem(icon: Icons.schedule, label: '15 Days'),
                            ],
                          ),
                          SizedBox(height: 10),
                          _IconRow(
                            items: [
                              _IconRowItem(icon: Icons.attach_money, label: '\$ 1,500 - 3,000'),
                              _IconRowItem(icon: Icons.group_outlined, label: '8 Proposals'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Client line
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1544005313-94ddf0286df2'),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eleanor Pena',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w700,
                                  )),
                              Text(
                                'Pro Buyer · Success Rate 100%',
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
                            children: const [
                              Text('Posted on',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                              SizedBox(height: 2),
                              Text('June 1, 2025',
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Project Description
                    const _SectionHeader('Project Description'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: _Para(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis velit eget auctor mollis. Curabitur sed dui neque. '
                              'Cras id dui nulla. Quisque tristique erat at eleifend volutpat. Aliquam elementum, ipsum at placerat volutpat, in a neque nec sapien, '
                              'quam primis in faucibus. In a neque nec quam primis sed velit. Fusce semper convallis dapibus. Integer sapien proin, vehicula in lorem non, '
                              'blandit vestibulum augue. Aenean ac posuere quam. Nam dapibus est at rutrum posuere. Quisque at auctor sapien, sit amet hendrerit tincidunt.'),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: _Para(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sapien nulla, ultrices a ligula interdum, tempus rutrum libero. '
                              'Nam tempus erat vel dui eleifend volutpat. Aliquam elementum, ipsum at placerat volutpat, quam orci pharetra dolor, at porttitor magna augue nec lectus. '
                              'In fermentum nisi.'),
                    ),
                    const SizedBox(height: 16),

                    // Skills
                    const _SectionHeader('Skills Required'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _SkillChip('Web Design'),
                          _SkillChip('eCommerce'),
                          _SkillChip('Shopify'),
                          _SkillChip('Wordpress'),
                          _SkillChip('UI/UX'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Proposals
                    const _SectionHeader('Project Proposal'),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: _ProposalCard(),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: _ProposalCard(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== Atoms & Molecules ======

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
        style:
        TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
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
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
    return Row(
      children: items
          .map((e) => Expanded(
        child: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 12),
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
      ))
          .toList()
        ..removeLast(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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

class _ProposalCard extends StatelessWidget {
  const _ProposalCard();

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
                    'https://images.unsplash.com/photo-1527980965255-d3b416303d12'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Eleanor Pena',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(
                    '2 Projects · Success Rate 100%',
                    style:
                    TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _Para(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.'),
          const SizedBox(height: 12),
          // Budget / Delivery aligned row
          Row(
            children: [
              const _LabeledText(label: 'Budget', value: '\$1200'),
              const Spacer(),
              const _LabeledText(label: 'Delivery Time', value: '14 days', alignEnd: true),
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
