import 'package:flutter/material.dart';

import 'my_event_project_details.dart';


class MyEventProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: ListView(
          children: [
            ProjectCard(
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$1,500 - \$3,000',
              duration: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              status: 'Accepted', // Example status
            ),
            ProjectCard(
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$1,500 - \$3,000',
              duration: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              status: 'Process', // Example status
            ),
            ProjectCard(
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$1,500 - \$3,000',
              duration: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              status: 'Declined', // Example status
            ),
            ProjectCard(
              title: 'Website Redesign for Local Business',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              budgetRange: '\$1,500 - \$3,000',
              duration: '15 Days',
              location: 'Brooklyn, NY',
              proposals: '8 Proposals',
              status: 'Completed', // Example status
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String budgetRange;
  final String duration;
  final String location;
  final String proposals;
  final String status;

  ProjectCard({
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
    Color statusColor;
    switch (status) {
      case 'Accepted':
        statusColor = Colors.green;
        break;
      case 'Process':
        statusColor = Colors.orange;
        break;
      case 'Declined':
        statusColor = Colors.red;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to the MyEventProjectDetail screen with right-to-left transition
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MyEventProjectDetail(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Apply right-to-left slide transition
              const begin = Offset(1.0, 0.0); // Right to Left
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16.0),
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                description,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budgetRange,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    duration,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    location,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    proposals,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

