import 'package:flutter/material.dart';


class MyEventProjectDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Keeping the dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);

          },
        ),
        title: Text(
          "Project Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title and Category
            Text(
              'Website Redesign for Local Business',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Design',
              style: TextStyle(color: Colors.orange, fontSize: 14),
            ),
            SizedBox(height: 24),

            // Project Date, Budget, and Proposals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Posted on June 1, 2023',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '\$1,500 - \$3,000',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Brooklyn, NY',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.folder, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '8 Proposals',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
                  radius: 18,
                ),
                SizedBox(width: 10),
                Text(
                  'Eleanor Pena',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(width: 10),
                Text(
                  '3 Projects - Success Rate 100%',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Complete Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 150, vertical: 12),
                ),
                child: Text(
                  'Complete',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Project Description Section
            Text(
              'Project Description',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum quis dui eget velit auctor mollis. Curabitur sed nunc vitae ex tincidunt porttitor blandit eget purus. Interdum et malesuada fames ac ante ipsum primis in faucibus.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 20),

            // Skills Required Section
            Text(
              'Skills Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                Chip(
                  label: Text('Web Design', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.grey[800],
                ),
                Chip(
                  label: Text('E-commerce', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.grey[800],
                ),
                Chip(
                  label: Text('Shopify', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.grey[800],
                ),
                Chip(
                  label: Text('UI/UX', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.grey[800],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
