import 'package:flutter/material.dart';

import 'util/app_colors.dart';
import 'util/images.dart';

class ReponsiveScreen extends StatelessWidget {
  const ReponsiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          var shortestSide = MediaQuery.of(context).size.shortestSide;
          bool isMobile = shortestSide < 600;
          if (isMobile) {
           return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Images.bgImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(child: Column(children: [])),
              ],
            );
          }
          return Center(child: Text("Other  Screen View"));
        },
      ),
    );
  }
}
