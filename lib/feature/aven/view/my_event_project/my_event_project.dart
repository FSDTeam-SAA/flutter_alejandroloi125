// import 'package:flutter/material.dart';
//
// import 'my_event_project_details.dart';
//
//
// class MyEventProject extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
//         child: ListView(
//           children: [
//             ProjectCard(
//               title: 'Website Redesign for Local Business',
//               description:
//               'Looking for an experienced web designer to revamp our company website. Need',
//               budgetRange: '\$1,500 - \$3,000',
//               duration: '15 Days',
//               location: 'Brooklyn, NY',
//               proposals: '8 Proposals',
//               status: 'Accepted', // Example status
//             ),
//             ProjectCard(
//               title: 'Website Redesign for Local Business',
//               description:
//               'Looking for an experienced web designer to revamp our company website. Need',
//               budgetRange: '\$1,500 - \$3,000',
//               duration: '15 Days',
//               location: 'Brooklyn, NY',
//               proposals: '8 Proposals',
//               status: 'Process', // Example status
//             ),
//             ProjectCard(
//               title: 'Website Redesign for Local Business',
//               description:
//               'Looking for an experienced web designer to revamp our company website. Need',
//               budgetRange: '\$1,500 - \$3,000',
//               duration: '15 Days',
//               location: 'Brooklyn, NY',
//               proposals: '8 Proposals',
//               status: 'Declined', // Example status
//             ),
//             ProjectCard(
//               title: 'Website Redesign for Local Business',
//               description:
//               'Looking for an experienced web designer to revamp our company website. Need',
//               budgetRange: '\$1,500 - \$3,000',
//               duration: '15 Days',
//               location: 'Brooklyn, NY',
//               proposals: '8 Proposals',
//               status: 'Completed', // Example status
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ProjectCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final String budgetRange;
//   final String duration;
//   final String location;
//   final String proposals;
//   final String status;
//
//   ProjectCard({
//     required this.title,
//     required this.description,
//     required this.budgetRange,
//     required this.duration,
//     required this.location,
//     required this.proposals,
//     required this.status,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Color statusColor;
//     switch (status) {
//       case 'Accepted':
//         statusColor = Colors.green;
//         break;
//       case 'Process':
//         statusColor = Colors.orange;
//         break;
//       case 'Declined':
//         statusColor = Colors.red;
//         break;
//       case 'Completed':
//         statusColor = Colors.blue;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         // Navigate to the MyEventProjectDetail screen with right-to-left transition
//         Navigator.push(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) => MyEventProjectDetail(),
//             transitionsBuilder: (context, animation, secondaryAnimation, child) {
//               // Apply right-to-left slide transition
//               const begin = Offset(1.0, 0.0); // Right to Left
//               const end = Offset.zero;
//               const curve = Curves.easeInOut;
//
//               var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//               var offsetAnimation = animation.drive(tween);
//
//               return SlideTransition(position: offsetAnimation, child: child);
//             },
//           ),
//         );
//       },
//       child: Card(
//         margin: EdgeInsets.only(bottom: 16.0),
//         color: Colors.grey[900],
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Text(
//                 title,
//                 style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: Text(
//                 description,
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     budgetRange,
//                     style: TextStyle(color: Colors.white, fontSize: 14),
//                   ),
//                   Text(
//                     duration,
//                     style: TextStyle(color: Colors.white, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     location,
//                     style: TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                   Text(
//                     proposals,
//                     style: TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: statusColor,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'my_event_project_details.dart';

// ---- palette to match your other screens ----
const _bg = Color(0xFF000000);
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;

class MyEventProject extends StatelessWidget {
  const MyEventProject({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: const [
        ProjectCard(
          category: 'Design',
          title: 'Website Redesign for Local Business',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          budgetRange: '\$ 1,500 - 3,000',
          duration: '15 Days',
          location: 'Brooklyn, NY',
          proposals: '8 Proposals',
          status: 'Accepted',
        ),
        ProjectCard(
          category: 'Design',
          title: 'Website Redesign for Local Business',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          budgetRange: '\$ 1,500 - 3,000',
          duration: '15 Days',
          location: 'Brooklyn, NY',
          proposals: '8 Proposals',
          status: 'Process',
        ),
        ProjectCard
          (
          category: 'Design',
          title: 'Website Redesign for Local Business',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          budgetRange: '\$ 1,500 - 3,000',
          duration: '15 Days',
          location: 'Brooklyn, NY',
          proposals: '8 Proposals',
          status: 'Declined',
        ),
        ProjectCard(
          category: 'Design',
          title: 'Website Redesign for Local Business',
          description:
          'Looking for an experienced web designer to revamp our company website. Need',
          budgetRange: '\$ 1,500 - 3,000',
          duration: '15 Days',
          location: 'Brooklyn, NY',
          proposals: '8 Proposals',
          status: 'Completed',
        ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String budgetRange;
  final String duration;
  final String location;
  final String proposals;
  final String status;

  const ProjectCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.budgetRange,
    required this.duration,
    required this.location,
    required this.proposals,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final styles = _statusStyle(status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>  MyEventProjectDetail(),
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: a.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // top line: category + status pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: styles.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: styles.fg,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // description
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _textDim, fontSize: 13.5, height: 1.25),
                  ),
                  const SizedBox(height: 10),

                  // info rows (2 columns per row)
                  _InfoRow(
                    leftIcon: Icons.attach_money,
                    leftText: budgetRange,
                    rightIcon: Icons.schedule,
                    rightText: duration,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    leftIcon: Icons.location_on_outlined,
                    leftText: location,
                    rightIcon: Icons.groups_2_outlined,
                    rightText: proposals,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData leftIcon;
  final String leftText;
  final IconData rightIcon;
  final String rightText;

  const _InfoRow({
    required this.leftIcon,
    required this.leftText,
    required this.rightIcon,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // left
        Expanded(
          child: Row(
            children: [
              Icon(leftIcon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  leftText,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // right
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(rightIcon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  rightText,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  const _StatusStyle(this.bg, this.fg);
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return const _StatusStyle(Color(0x332E8BFD), Color(0xFF2E8BFD)); // light blue bg, blue text
    case 'process':
      return const _StatusStyle(Color(0x33FFA000), Color(0xFFFFA000)); // amber
    case 'declined':
      return const _StatusStyle(Color(0x33E53935), Color(0xFFE53935)); // red
    case 'completed':
      return const _StatusStyle(Color(0x332AA86F), Color(0xFF2AA86F)); // green
    default:
      return const _StatusStyle(Color(0x33424242), Colors.white70);
  }
}
