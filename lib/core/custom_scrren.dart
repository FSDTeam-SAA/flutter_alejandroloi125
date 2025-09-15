import 'package:flutter/material.dart';

import 'util/images.dart';


class CustomBackground extends StatelessWidget {
  final Widget child; // screen এর content
  const CustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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


              SafeArea(child: child),
            ],
          );
        }

        return const Center(
          child: Text("Other Screen View"),
        );
      },
    );
  }
}
