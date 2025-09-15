import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';

class PillTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabNames; // dynamic tab names

  const PillTabBar({
    super.key,
    required this.tabController,
    required this.tabNames,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabNames.length;

          return Stack(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
                child: TabBar(
                  controller: tabController,
                  dividerColor: Colors.transparent,
                  labelPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: ShapeDecoration(
                    color: AppColors.bottomColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  tabs: tabNames.map((name) => Tab(text: name)).toList(),
                ),
              ),
              // subtle separators beneath the indicator
              for (int i = 1; i < tabNames.length; i++)
                Positioned(
                  left: tabWidth * i,
                  top: 6,
                  bottom: 6,
                  child: Container(width: 1, color: border),
                ),
            ],
          );
        },
      ),
    );
  }
}
