import 'package:alejandroloi/core/common/widgets/live_action_card.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/home/widgets/botton_card.dart';
import 'package:alejandroloi/feature/home/widgets/investdesk_card.dart';
import 'package:alejandroloi/feature/home/widgets/project_card.dart';
import 'package:alejandroloi/feature/investments/view/investment_screen.dart';
import 'package:alejandroloi/feature/investments/widgets/progrees.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auctions/view/auction_screen.dart';
import '../../project/view/project.dart';

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
       toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            children: const [
              Icon(Icons.account_circle_outlined, color: Colors.white, size: 60),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Text("Location", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Icon(Icons.notifications_on_outlined, color: Colors.white, size: 30),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(   // <-- scrollable parent
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BottomCard(
              imagePath: Images.currency,
              title: "Investments",
              subtitle: "Develop Investment Strategy and Engage with Potential Funders.",
              onTap: () {
                Get.to(
                      () => const InvestmentsScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
            const SizedBox(height: 15),
            BottomCard(
              imagePath: Images.layout,
              title: "Project",
              subtitle: "Post a need or offer to complete someone else's project",
              onTap: () {
                Get.to(
                      () => const ProjectScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },

            ),
            const SizedBox(height: 15),
            BottomCard(
              imagePath: Images.key,
              title: "Action",
              subtitle: "Participate in the live product auction by placing your bid.",
              onTap: () {
                Get.to(
                      () => const AuctionScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
            const SizedBox(height: 20),
            rowText(leadingText: "Live Action", trailingText: "See all"),
            const SizedBox(height: 10),
            SizedBox(
              height: 200, // ListView height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 160, // fix card width
                      child: LiveAuctionCards(
                        auction: Auctions(
                          imageUrl: "assets/images/tree.jpg",
                          title: "Live Art Auction",
                          currentPrice: 1200.5,
                          viewers: 45,
                        ),
                        onTap: () => print("Auction clicked!"),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            rowText(leadingText: "Invest Desk", trailingText: "See all"),

          SizedBox(height: 300,
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_,index){
            return  Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: (){
                  Get.to(InvestmentsScreen());
                },
                child: InvestDeskCard(
                    type: "Agriculture",
                    imagePath: "assets/images/tree.jpg",
                    title: "Urban Farming Initiative",
                    progressBar: ProgressBar(value: 6, color: AppColors.bottomColor1,),
                    price: "455.3434",
                    percent:"10",

                  ),
              ),
            );
            }),
          ),
            rowText(leadingText: "Project Proposal", trailingText: "See all"),

            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
               // padding: const EdgeInsets.symmetric(horizontal: 12), // left-right padding for ListView
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 300, height: 222,// card width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.fieldColor,
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                            Text("Design",style: bodyText1,),
                              Text("Website Redesign for Local Business",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.white),),
                              Text("Looking for an experienced web designer to revamp our company website. Need ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.white),),
                              Row(children: [],)
                          ],),
                        )
                      ),
                    ),
                  );
                },
              ),
            )




          ],
        ),
      ),
    );
  }
}


Widget rowText({
  required String leadingText,
  required String trailingText,
  VoidCallback? onTap,

}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leadingText,
          style: headingText.copyWith(fontSize: 18),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            trailingText,
            style: TextStyle(fontSize: 12,color: AppColors.bottomColor1,fontWeight: FontWeight.w600)
          ),
        ),
      ],
    ),
  );
}

