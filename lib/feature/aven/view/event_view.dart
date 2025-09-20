import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';

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

  // (Optional) if parent rebuilds EventView with a different initialTab
  // @override
  // void didUpdateWidget(covariant EventView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.initialTab != widget.initialTab &&
  //       _tabController.index != widget.initialTab.index) {
  //     _tabController.animateTo(widget.initialTab.index);
  //   }
  // }

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
