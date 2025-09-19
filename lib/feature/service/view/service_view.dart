import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:alejandroloi/feature/app_ground.dart';
import 'package:alejandroloi/feature/home/view/home_view.dart';
import 'package:flutter/material.dart';


import 'my_auctions/my_auctions.dart';
import 'my_investments/my_investments.dart';
import 'my_projects/my_projects.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key,this.initialIndex = 0});
  final int initialIndex;

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,initialIndex: widget.initialIndex.clamp(0, 2),);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Services",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AppGround(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, animation, __, child) {
                  final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
                    child: child,
                  );
                },
              ),
                  (route) => false,
            );
          },
        ),

      ),
     // extendBodyBehindAppBar: true, // Scaffold property
      body: Column(
        children: [
          PillTabBar(tabController: _tabController,tabNames: ["Investments","Project","Auctions"],),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Center(child: Text("Live Services")),
                // Center(child: Text("Upcoming Services")),
                // Center(child: Text("Ended Services")),
                MyInvestmentScreen(),
                MyProjectScreen(),
                MyAuctionScreen(),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
