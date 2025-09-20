import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyEventInvestmentDetail extends StatelessWidget {
  const MyEventInvestmentDetail({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0F12);
    const cardBg = Color(0xFF15181C);
    const border = Color(0xFF242931);
    const accent = Color(0xFFFF8A34);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        // No AppBar — we use the custom back button on the image
        backgroundColor: bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              // main card
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
                    // hero image + top actions + author row
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              'assets/images/wind-mill.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.black26,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
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
                        // author chip
                        const Positioned(
                          left: 12,
                          bottom: 10,
                          child: _AuthorChip(),
                        ),
                      ],
                    ),

                    // body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Badge(text: 'Agriculture', color: accent),
                          SizedBox(height: 8),
                          Text(
                            'Urban Farming Initiative',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          _Para(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                          ),
                          SizedBox(height: 12),
                          _InfoBar(
                            icon: Icons.location_on_outlined,
                            label: 'New York, NY',
                          ),
                          SizedBox(height: 16),
                          _ProgressBar(
                            value: 0.45,
                            background: Color(0xFF1E232A),
                            fill: accent,
                          ),
                          SizedBox(height: 8),
                          _MetricsRow(),
                          SizedBox(height: 18),
                          _SectionTitle('About This Project'),
                          SizedBox(height: 8),
                          _Para(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis velit eget auctor mollis. Curabitur sed dui neque.'),
                          SizedBox(height: 10),
                          _Para(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sapien nulla, ultrices a ligula interdum, tempus rutrum libero. Nam tempus erat vel dui eleifend volutpat. Aliquam elementum, ipsum at placerat volutpat, quam orci pharetra dolor, at porttitor magna augue nec lectus. In fermentum nisi.'),
                          SizedBox(height: 16),
                          _SectionTitle('Gallery'),
                          SizedBox(height: 8),
                          _GalleryRow(),
                          SizedBox(height: 16),
                          _SectionTitle('Investment Terms'),
                          SizedBox(height: 6),
                          _Bullet('Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
                          _Bullet('Quisque fermentum tortor nec pharetra viverra.'),
                          _Bullet('Fusce id metus at lacus leo convallis convallis.'),
                          _Bullet('Duis mollis dolor sit amet tortor egestas, vel consectetur enim blandit.'),
                          _Bullet('Duis lacus augue velit eu sodales, sit amet tristique mauris fringilla.'),
                          _Bullet('Sed in mi vel velit ultrices dignissim.'),
                          SizedBox(height: 16),
                          _SectionTitle('Investor'),
                          SizedBox(height: 8),
                          InvestorTile(
                            name: 'Eleanor Pena',
                            subtitle: '3 Investments',
                            amount: '\$1000',
                            avatar: 'https://picsum.photos/200',
                          ),

                          InvestorTile(
                            name: 'Eleanor Pena',
                            subtitle: '3 Investments',
                            amount: '\$1000',
                            avatar: 'https://picsum.photos/200',
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // // Bottom CTA
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: accent,
              //       foregroundColor: Colors.black,
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       elevation: 0,
              //     ),
              //     onPressed: () {},
              //     child: const Text('Invest Now'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== atoms & molecules ======

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

class _AuthorChip extends StatelessWidget {
  const _AuthorChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eleanor Pena',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '@eleanorp',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const _TinyPill(text: '4.8'),
        const SizedBox(width: 6),
        const _TinyPill(text: '21k'),
      ],
    );
  }
}

class _TinyPill extends StatelessWidget {
  final String text;
  const _TinyPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBar({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
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
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color background;
  final Color fill;
  const _ProgressBar({
    required this.value,
    required this.background,
    required this.fill,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final filled = (width * value).clamp(0.0, width);
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: filled,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _Metric(top: '45%', bottom: 'of \$25,000'),
        _Metric(top: '28', bottom: 'Backers'),
        _Metric(top: '10', bottom: 'Days left'),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String top;
  final String bottom;
  const _Metric({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          top,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          bottom,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 16,
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
      style: TextStyle(
        color: Colors.white.withOpacity(0.78),
        height: 1.45,
      ),
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _RoundedImage(
            'https://images.unsplash.com/photo-1501004318641-b39e6451bec6',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _RoundedImage(
            'https://images.unsplash.com/photo-1509395176047-4a66953fd231',
          ),
        ),
      ],
    );
  }
}

class _RoundedImage extends StatelessWidget {
  final String url;
  const _RoundedImage(this.url);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}

// class _InvestorTile extends StatelessWidget {
//   final String name;
//   final String time;
//   final String amount;
//   final String avatar;
//   const _InvestorTile({
//     required this.name,
//     required this.time,
//     required this.amount,
//     required this.avatar,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const border = Color(0xFF2A313A);
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1F26),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: border),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           CircleAvatar(backgroundImage: NetworkImage(avatar), radius: 18),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name,
//                     style: const TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 2),
//                 Text(
//                   time,
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(0.7), fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFF8A34).withOpacity(0.14),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: const Color(0xFFFF8A34).withOpacity(0.7)),
//             ),
//             child: Text(
//               amount,
//               style: const TextStyle(
//                 color: Color(0xFFFF8A34),
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class InvestorTile extends StatelessWidget {
  final String name;
  final String subtitle; // e.g. "3 Investments"
  final String amount;   // e.g. "$1000"
  final String avatar;

  const InvestorTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg  = Color(0xFF1A1F26);
    const border  = Color(0xFF2A313A);
    const accent  = Color(0xFFFF6A00);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + name + subtitle
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Amount row: label left, orange amount right
          Row(
            children: [
              const Text(
                'Investment Amount:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
