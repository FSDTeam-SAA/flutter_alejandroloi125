import 'package:flutter/material.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/core/common/widgets/pilltabs.dart';
import 'package:alejandroloi/feature/investments/view/create_investments.dart';
import 'package:alejandroloi/feature/project/view/create_project_view.dart';
import 'package:alejandroloi/feature/auctions/view/create_auctions_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../core/language/language_controller.dart';

class CreateServicesView extends StatefulWidget {
  const CreateServicesView({super.key});

  @override
  State<CreateServicesView> createState() => _CreateServicesViewState();
}

class _CreateServicesViewState extends State<CreateServicesView>
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
    final langController = Get.put(LanguageController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(langController.t('create_services'), style: headingText),

        //title: Text(widget.langController.t('create_services'), style: headingText),
        //title:  Text(widget.langController.t('my_services'), style: TextStyle(color: Colors.white)),
        //title: Text(langController.t('create_services'), style: headingText),
      ),
      body: Column(
        children: [
          PillTabBar(
            tabController: _tabController,
            tabNames:  [(langController.t('investments')), (langController.t('project')), (langController.t('auctions'))],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const CreateInvestmentsView(),
                const CreateProjectView(),
                CreateAuctionsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
