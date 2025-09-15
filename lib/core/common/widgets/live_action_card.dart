import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';

class Auction {
  final String imageUrl;
  final String title;
  final double currentPrice;
  final int viewers;

  Auction({
    required this.imageUrl,
    required this.title,
    required this.currentPrice,
    required this.viewers,
  });
}

class LiveAuctionCard extends StatelessWidget {
  final Auction auction;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color liveBadgeColor;
  final Color viewersBadgeColor;

  const LiveAuctionCard({
    super.key,
    required this.auction,
    this.onTap,
    this.borderRadius = 14,
    this.liveBadgeColor = Colors.redAccent,
    this.viewersBadgeColor = const Color(0x66000000),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.fieldColor,
          //color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                   child:  Image.asset(auction.imageUrl ,fit: BoxFit.cover),
                   // child: Image.network(auction.imageUrl, fit: BoxFit.cover),
                  ),
                ),

                // LIVE badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF1A26),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,color: Colors.white
                      ),
                    ),
                  ),
                ),

                // Viewers badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      //color: AppColors.fieldColor,
                      color: Colors.white60,
                      //color: viewersBadgeColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, size: 14,color: Colors.black,),
                        const SizedBox(width: 4),
                        Text('${auction.viewers}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Title & price
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${auction.currentPrice}',
                    style: TextStyle(
                      color: AppColors.bottomColor1,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
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
