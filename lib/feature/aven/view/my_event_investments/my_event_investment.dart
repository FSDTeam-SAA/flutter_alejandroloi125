import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'my_event_investment_detail.dart';


class MyEventInvestmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventScreen(),
    );
  }
}

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: ListView(
          children: [
            EventCard(
              image: 'assets/images/garden.jpg',
              title: 'Urban Farming Initiative',
              description: 'Looking for an experienced web designer to revamp our company website. Need',
              progress: '100%',
              amount: '\$25,000',
              daysLeft: '10 days left',
            ),
            EventCard(
              image: 'assets/images/diamond.jpg',
              title: 'Urban Farming Initiative',
              description: 'Looking for an experienced web designer to revamp our company website. Need',
              progress: '45%',
              amount: '\$25,000',
              daysLeft: '10 days left',
            ),
            EventCard(
              image: 'assets/images/wind-mill.jpg',
              title: 'Urban Farming Initiative',
              description: 'Looking for an experienced web designer to revamp our company website. Need',
              progress: '60%',
              amount: '\$25,000',
              daysLeft: '10 days left',
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String progress;
  final String amount;
  final String daysLeft;

  EventCard({
    required this.image,
    required this.title,
    required this.description,
    required this.progress,
    required this.amount,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
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
                  progress,
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
                Text(
                  amount,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                // bottom: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  daysLeft,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the ProjectDetailsScreen with a right-to-left transition
                    Get.to(
                      MyEventInvestmentDetail(),
                      transition: Transition.rightToLeft,  // Set right-to-left transition
                      duration: Duration(milliseconds: 300),  // Set the transition duration (optional)
                    );
                  },
                  child: Text(
                    'View Details',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
