import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auctions/view/auction_screen.dart';
import 'package:alejandroloi/feature/auctions/view/create_auctions_view.dart';
import 'package:alejandroloi/feature/aven/view/my_event_auctions/my_event_aution_details.dart';
import 'package:alejandroloi/feature/project/view/create_project_view.dart';
import 'package:flutter/material.dart';

import '../../investments/view/create_investments.dart';
import 'my_event_auctions/my_event_auction.dart';
import 'my_event_investments/my_event_investment.dart';
import 'my_event_project/my_event_project.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this);

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
        title: const Text("My Event", style: headingText,),
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: Column(
        children: [
          PillTabBar(tabController: _tabController,tabNames: ["Investments","Project","Auctions"],),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MyEventInvestmentScreen(),
                MyEventProject(),
                //AuctionScreen(),
                MyEventAuction(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
