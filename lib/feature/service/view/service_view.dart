import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:flutter/material.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView>
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
        title: const Text("My Services",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
     // extendBodyBehindAppBar: true, // Scaffold property
      body: Column(
        children: [
          PillTabBar(tabController: _tabController,tabNames: ["Investments","Project","Auctions"],),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                Center(child: Text("Live Services")),
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
