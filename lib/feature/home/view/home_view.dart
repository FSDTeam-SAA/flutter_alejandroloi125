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
                    Text("Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),),
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
              imagePath: Images.currency, title: "Investments",
              subtitle: "Develop Investment Strategy and Engage with Potential Funders.",
              onTap: () {
                Get.to(() => const InvestmentsScreen(),
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
                Get.to(() => const ProjectScreen(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ProjectMiniCard(
                      category: 'Design',
                      title: 'Website Redesign for Local Business',
                      blurb:
                      'Looking for an experienced web designer to revamp our company website. Need',
                      priceRange: '\$ 1,500 - 3,000',
                      duration: '15 Days',
                      location: 'Brooklyn, NY',
                      proposals: '8 Proposals',
                      avatars: const [
                        'https://i.pravatar.cc/60?img=12',
                        'https://i.pravatar.cc/60?img=22',
                        'https://i.pravatar.cc/60?img=32',
                        'https://i.pravatar.cc/60?img=42',
                      ],
                      onTap: () {
                        // e.g. Get.to(() => ProjectDetailScreen());
                      },
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



class ProjectMiniCard extends StatelessWidget {
  const ProjectMiniCard({
    super.key,
    required this.category,
    required this.title,
    required this.blurb,
    required this.priceRange,
    required this.duration,
    required this.location,
    required this.proposals,
    this.avatars = const [],
    this.onTap,
  });

  final String category;
  final String title;
  final String blurb;
  final String priceRange;
  final String duration;
  final String location;
  final String proposals;
  final List<String> avatars;
  final VoidCallback? onTap;

  static const _orange = Color(0xFFFF8C3B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderCol = const Color(0xFF2B2C31);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category (small orange text)
            Text(
              category,
              style: const TextStyle(
                color: _orange,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // Blurb
            Text(
              blurb,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),

            // Row 1: $ and Days
            Row(
              children: [
                Expanded(
                  child: _MetaItem(
                    icon: Icons.attach_money_rounded,
                    text: priceRange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetaItem(
                    icon: Icons.timelapse_rounded,
                    text: duration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Location and Proposals
            Row(
              children: [
                Expanded(
                  child: _MetaItem(
                    icon: Icons.place_rounded,
                    text: location,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetaItem(
                    icon: Icons.group_rounded,
                    text: proposals,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2B2C31), height: 1),
            const SizedBox(height: 10),

            // Avatars + CTA
            Row(
              children: [
                _AvatarStack(urls: avatars),
                const Spacer(),
                Text(
                  'View Details',
                  style: const TextStyle(
                    color: _orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 0), // keeps height consistent if text wraps
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double overlap = 12;
    final extras = urls.length > 3 ? urls.length - 3 : 0;

    return SizedBox(
      height: size,
      width: size + (urls.isEmpty ? 0 : (urls.length.clamp(0, 3) - 1) * overlap) + (extras > 0 ? overlap + 10 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < urls.length && i < 3; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: size / 2 - 1.5,
                  backgroundImage: NetworkImage(urls[i]),
                ),
              ),
            ),
          if (extras > 0)
            Positioned(
              left: 3 * overlap,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B30),
                  border: Border.all(color: Colors.black, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '+$extras',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
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

