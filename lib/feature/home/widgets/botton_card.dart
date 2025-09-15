

import 'package:flutter/material.dart';
import 'package:alejandroloi/core/util/app_colors.dart';

class BottomCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const BottomCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColors.fieldColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// leading icon / image
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Image.asset(imagePath, height: 28, width: 28),
            ),
            const SizedBox(width: 12),

            /// text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}








/*
import 'package:flutter/material.dart';
import 'package:alejandroloi/core/util/app_colors.dart';

Widget bottomCard({
  required String imagePath,
  required Widget child,
}) {
  return Container(
    height: 86,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: AppColors.fieldColor,
    ),
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Image.asset(imagePath, height: 30, width: 30),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [child],
          ),
        ),
      ],
    ),
  );
}
*/
