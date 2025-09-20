import 'package:flutter/material.dart';

// ---- palette to match the rest of your app ----
const _bg = Color(0xFF000000);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;
const _chipBg = Color(0xFF2C2C30);

class MyEventProjectDetail extends StatelessWidget {
  const MyEventProjectDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top controls (back + share on left, heart on right)
              Row(
                children: [
                  _roundIcon(Icons.arrow_back, () => Navigator.maybePop(context)),
                  const SizedBox(width: 8),
                  // _roundIcon(Icons.ios_share_outlined, () {}),
                  const Spacer(),
                  _roundIcon(Icons.favorite_border, () {}),
                ],
              ),
              const SizedBox(height: 16),

              // category
              const Text(
                'Design',
                style: TextStyle(
                  color: _accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              // title
              const Text(
                'Website Redesign for Local Business',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc interdum metus eu egestas pharetra. Fusce bibendum odio et venenatis efficitur.',
                style: TextStyle(color: _textDim, fontSize: 13.5, height: 1.35),
              ),
              const SizedBox(height: 16),

              // info rows
              _twoCols(
                leftIcon: Icons.attach_money,
                leftText: '1,500-3,000',
                rightIcon: Icons.schedule,
                rightText: '15 Days',
              ),
              const SizedBox(height: 8),
              _twoCols(
                leftIcon: Icons.location_on_outlined,
                leftText: 'Brooklyn, NY',
                rightIcon: Icons.groups_2_outlined,
                rightText: '8 Proposals',
              ),
              const SizedBox(height: 14),

              // owner + posted badge
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/images/person.png'),
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Eleanor Pena',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('3 Projects • Success Rate 100%',
                            style: TextStyle(color: _textDim, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Posted on',
                          style: TextStyle(color: _textDim, fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text('June 1, 2025',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // complete button (full-width)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 18),

              // description
              const Text(
                'Project Description',
                style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis. Curabitur sed nunc vitae ex tincidunt porttitor blandit eget purus. Interdum et malesuada fames ac ante ipsum primis in faucibus. In a neque at neque convallis mollis eget sed velit. Fusce semper convallis dapibus.',
                style: TextStyle(color: _textDim, fontSize: 13.5, height: 1.45),
              ),
              const SizedBox(height: 12),
              const Text(
                'Integer sapien mi, vehicula in lorem non, blandit vestibulum augue. Aenean ac posuere quam. Nam dapibus est ut rutrum posuere. Quisque at auctor sapien, sit amet hendrerit tincidunt.',
                style: TextStyle(color: _textDim, fontSize: 13.5, height: 1.45),
              ),
              const SizedBox(height: 18),

              // skills
              const Text(
                'Skills Required',
                style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _SkillChip('Web Design'),
                  _SkillChip('E-commerce'),
                  _SkillChip('Shopify'),
                  _SkillChip('WordPress'),
                  _SkillChip('UI/UX'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // round icon button used in header
  static Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

// --- helpers ---
class _twoCols extends StatelessWidget {
  final IconData leftIcon;
  final String leftText;
  final IconData rightIcon;
  final String rightText;

  const _twoCols({
    required this.leftIcon,
    required this.leftText,
    required this.rightIcon,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _iconText(leftIcon, leftText)),
        const SizedBox(width: 10),
        Expanded(child: _iconText(rightIcon, rightText, alignEnd: true)),
      ],
    );
  }

  static Widget _iconText(IconData icon, String text, {bool alignEnd = false}) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    return alignEnd ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [row]) : row;
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
    );
  }
}




// import 'package:flutter/material.dart';
//
//
// class MyEventProjectDetail extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Keeping the dark background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//
//           },
//         ),
//         title: Text(
//           "Project Details",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.favorite_border, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Project Title and Category
//             Text(
//               'Website Redesign for Local Business',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Design',
//               style: TextStyle(color: Colors.orange, fontSize: 14),
//             ),
//             SizedBox(height: 24),
//
//             // Project Date, Budget, and Proposals
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.access_time, color: Colors.white, size: 16),
//                     SizedBox(width: 8),
//                     Text(
//                       'Posted on June 1, 2023',
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.attach_money, color: Colors.white, size: 16),
//                     SizedBox(width: 8),
//                     Text(
//                       '\$1,500 - \$3,000',
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.location_on, color: Colors.white, size: 16),
//                     SizedBox(width: 8),
//                     Text(
//                       'Brooklyn, NY',
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.folder, color: Colors.white, size: 16),
//                     SizedBox(width: 8),
//                     Text(
//                       '8 Proposals',
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//
//             // User Info
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
//                   radius: 18,
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   'Eleanor Pena',
//                   style: TextStyle(color: Colors.white, fontSize: 14),
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   '3 Projects - Success Rate 100%',
//                   style: TextStyle(color: Colors.white60, fontSize: 12),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//
//             // Complete Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange[800],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 150, vertical: 12),
//                 ),
//                 child: Text(
//                   'Complete',
//                   style: TextStyle(
//                       color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//
//             // Project Description Section
//             Text(
//               'Project Description',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis. Curabitur sed nunc vitae ex tincidunt porttitor blandit eget purus. Interdum et malesuada fames ac ante ipsum primis in faucibus.',
//               style: TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//             SizedBox(height: 20),
//
//             // Skills Required Section
//             Text(
//               'Skills Required',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Wrap(
//               spacing: 12,
//               runSpacing: 10,
//               children: [
//                 Chip(
//                   label: Text('Web Design', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//                 Chip(
//                   label: Text('E-commerce', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//                 Chip(
//                   label: Text('Shopify', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//                 Chip(
//                   label: Text('UI/UX', style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.grey[800],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
