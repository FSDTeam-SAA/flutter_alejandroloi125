// lib/feature/home/widgets/investdesk_card.dart
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';

class InvestDeskCard extends StatelessWidget {
  final String? imagePath;
  final String? title;
  final String? type;     // "Agriculture" (NO brackets)
  final String? percent;  // "45"
  final Widget? progressBar;
  final String? price;    // "25000"

  const InvestDeskCard({
    super.key,
    this.imagePath,
    this.title,
    this.type,
    this.percent,
    this.price,
    this.progressBar,
  });

  @override
  Widget build(BuildContext context) {
    final percentText = (percent == null || percent!.isEmpty)
        ? '0% funded'
        : '${percent!.replaceAll('%', '')}% funded';

    final priceText = (price == null || price!.isEmpty) ? '\$ 0' : '\$ $price';

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.fieldColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagePath != null && imagePath!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.asset(
                imagePath!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type != null && type!.isNotEmpty)
                    Text(
                      type!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.bottomColor1,
                      ),
                    ),
                  if (title != null && title!.isNotEmpty)
                    Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (progressBar != null) ...[
                    const SizedBox(height: 8),
                    progressBar!,
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          percentText, // “45% funded”
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xffA8A8A8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          priceText,   // “$ 25,000”
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
