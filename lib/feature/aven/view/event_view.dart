import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../app_ground.dart';
import 'my_event_investments/my_event_investment.dart';
import 'my_event_project/my_event_project.dart';
import 'my_event_auctions/my_event_auction.dart';

enum EventTab { investments, project, auctions }

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
      length: 3,
      vsync: this,
    );
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
        title: const Text('My Event', style: headingText),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offAll(() => const AppGround(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          ),
        ),
      ),
      body: Column(
        children: [
          PillTabBar(
            tabController: _tabController,
            tabNames: const ['Investments', 'Project', 'Auctions'],
          ),
          Expanded(

            child: TabBarView(
              controller: _tabController,
              children: const [
                MyEventInvestmentScreen(),
                MyEventProject(),
                MyEventAuction(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
