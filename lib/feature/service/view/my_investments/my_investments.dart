import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/services.dart';
import 'my_investment_details.dart';

class MyInvestmentScreen extends StatefulWidget {
  const MyInvestmentScreen({super.key});

  @override
  State<MyInvestmentScreen> createState() => _MyInvestmentScreenState();
}

class _MyInvestmentScreenState extends State<MyInvestmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),

      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF0D0F12),
      //   elevation: 0,
      //   centerTitle: false,
      //   surfaceTintColor: Colors.transparent,        // avoid gray M3 tint
      //   foregroundColor: Colors.white,               // <-- makes title & icons white
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   // systemOverlayStyle: SystemUiOverlayStyle.light, // status bar: light icons
      //   // leading: IconButton(
      //   //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
      //   //   tooltip: 'Back',
      //   //   onPressed: () => Navigator.of(context).pop(), // or Get.back()
      //   // ),
      //   // title: const Text(
      //   //   'My Services',
      //   //   style: TextStyle(
      //   //     color: Colors.white,                      // explicit title color
      //   //     fontWeight: FontWeight.w800,
      //   //   ),
      //   // ),
      // ),


      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            _InvestmentCard(
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              imageUrl:
              'assets/images/agriculture.jpg', // replace with your asset
              category: 'Agriculture',
              title: 'Urban Farming Initiative',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              progress: 0.45,
              goalText: '\$25,000',
              daysLeftText: '10 days left',
              showCompleted: false,
            ),
            SizedBox(height: 16),
            _InvestmentCard(
              status: 'In Progress',
              statusColor: Color(0xFFFF8A34),
              imageUrl:
              'assets/images/wind-mill.jpg', // replace with your asset
              category: 'Agriculture',
              title: 'Urban Farming Initiative',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              progress: 0.45,
              goalText: '\$25,000',
              daysLeftText: '10 days left',
              showCompleted: false,
            ),
            SizedBox(height: 16),
            _InvestmentCard(
              status: 'Completed',
              statusColor: Color(0xFF58D38C),
              imageUrl:
              'assets/images/garden.jpg', // replace with your asset
              category: 'Agriculture',
              title: 'Urban Farming Initiative',
              description:
              'Looking for an experienced web designer to revamp our company website. Need',
              progress: 1.0,
              goalText: '\$25,000',
              daysLeftText: '2 days left',
              showCompleted: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String imageUrl;
  final String category;
  final String title;
  final String description;
  final double progress;
  final String goalText;
  final String daysLeftText;
  final bool showCompleted;

  const _InvestmentCard({
    required this.status,
    required this.statusColor,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    required this.goalText,
    required this.daysLeftText,
    required this.showCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = const Color(0xFF15181C);
    final accent = const Color(0xFFFF8A34);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242931)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // Image + status badge
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.7)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),


                // replace your Row(...) with this:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // progress bar (full width)
                    _ProgressBar(
                      value: progress,                            // 0..1
                      background: const Color(0xFF1E232A),
                      fill: const Color(0xFFFF6A00),              // accent
                      height: 10,
                      radius: 6,
                    ),
                    const SizedBox(height: 6),

                    // labels row
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).round()}% of $goalText',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,          // bold like the shot
                          ),
                        ),
                        const Spacer(),
                        Text(
                          daysLeftText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),


                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [


                    Expanded(
                      child: OutlinedButton(

                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          // orange border (slightly dim if disabled)
                          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                            final disabled = states.contains(WidgetState.disabled);
                            return BorderSide(color: Color(0xFFFF6A00).withOpacity(disabled ? 0.45 : 1), width: 1.5);
                          }),
                          // orange label (dim if disabled)
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            final disabled = states.contains(WidgetState.disabled);
                            return Color(0xFFFF6A00).withOpacity(disabled ? 0.45 : 1);
                          }),
                          overlayColor: WidgetStateProperty.all(Color(0xFFFF6A00).withOpacity(0.08)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        onPressed: showCompleted ? null : () { /* delete action */ },
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {

                          Get.to(
                                () => const MyInvestmentDetailScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );



                        },
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _ProgressBar extends StatelessWidget {
  final double value;              // 0..1
  final Color background;
  final Color fill;
  final double height;
  final double radius;

  const _ProgressBar({
    required this.value,
    required this.background,
    required this.fill,
    this.height = 10,
    this.radius = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: background,
        valueColor: AlwaysStoppedAnimation<Color>(fill),
      ),
    );
  }
}

