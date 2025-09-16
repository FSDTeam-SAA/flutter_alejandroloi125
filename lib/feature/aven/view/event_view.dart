import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:flutter/material.dart';

import '../../investments/view/create_investments.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text("My Event", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: Column(
        children: [
          PillTabBar(tabController: _tabController,tabNames: ["Investments","Project","Actions"],),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CreateInvestmentsView(),
                Center(child: Text("Upcoming Services")),
                Center(child: Text("Ended Services")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
