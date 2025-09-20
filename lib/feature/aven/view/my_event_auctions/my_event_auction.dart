import 'package:flutter/material.dart';

import 'my_event_aution_details.dart';



class MyEventAuction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text('Auction Items'),
        //   backgroundColor: Colors.red,
        // ),
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              AuctionItem(
                imageUrl: 'assets/images/diamond.jpg', // Replace with actual asset
                title: 'Gaming Console',
                finalBid: '\$1,200',
                status: 'Won',
                date: 'Ended jun 10',
              ),
              AuctionItem(
                imageUrl: 'assets/images/watch.jpg', // Replace with actual asset
                title: 'Gaming Console',
                finalBid: '\$1,200',
                status: 'Won',
                date: 'Ended jun 10',
              ),
              AuctionItem(
                imageUrl: 'assets/images/earpod.jpg', // Replace with actual asset
                title: 'Gaming Console',
                finalBid: '\$1,200',
                status: 'Live',
                date: 'Ended jun 10',
              ),
              AuctionItem(
                imageUrl: 'assets/images/agriculture.jpg', // Replace with actual asset
                title: 'Gaming Console',
                finalBid: '\$1,200',
                status: 'Loss',
                date: 'Ended jun 10',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuctionItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String finalBid;
  final String status;
  final String date;

  const AuctionItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.finalBid,
    required this.status,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.0),
        leading: Image.asset(
          imageUrl,
          width: 50,
          height: 50,
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              finalBid,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              date,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: Colors.white),
          ),
        ),

        //  Navigate to details on tap
          // tap handler
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              _slideRightToLeft(const MyEventAutionDetailScreen()),
            );
          }


      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Won':
        return Colors.green;
      case 'Live':
        return Colors.orange;
      case 'Loss':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

Route _slideRightToLeft(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
