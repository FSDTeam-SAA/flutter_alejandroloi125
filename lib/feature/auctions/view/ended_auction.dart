import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/util/app_colors.dart';
import '../controller/auction_controller.dart';

class EndedAuctionView extends StatelessWidget {
  const EndedAuctionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuctionController>();
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      // 🌀 Loading state
      if (controller.loading.value) {
        return const Center(
          child: CircularProgressIndicator(backgroundColor: Colors.white),
        );
      }

      // ❌ Error state
      else if (controller.error.value.isNotEmpty) {
        return Center(
          child: Text(
            controller.error.value,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        );
      }

      // 📭 Empty data state
      else if (controller.endedAuctions.isEmpty) {
        return const Center(
          child: Text(
            'No ended auctions found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        );
      }

      // ✅ Data loaded state
      else {
        return ListView.builder(
          itemCount: controller.endedAuctions.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final auction = controller.endedAuctions[index];

            return Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼️ Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: auction.image.isNotEmpty
                          ? Image.network(
                        auction.image[0].url,
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 108,
                        height: 108,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // 📄 Auction details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(auction.name, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white,),),
                          const SizedBox(height: 4),


                          Row(
                            children: [
                              const Text("First Bid: ", style: TextStyle(color: Colors.white70),),
                              Text("\$${auction.startingBid}", style: TextStyle(color: AppColors.bottomColor1, fontWeight: FontWeight.w600,),),
                            ],
                          ),
                          const SizedBox(height: 2),

                          Row(
                            children: [
                              const Text("Final Bid: ", style: TextStyle(color: Colors.white70),),
                             /* Text("\$${auction.endingBid ?? auction.startingBid}",
                                style: TextStyle(
                                  color: AppColors.bottomColor1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),*/
                            ],
                          ),
                          const SizedBox(height: 2),

                          Row(
                            children: [
                              const Icon(
                                Icons.watch_later_outlined, size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text("Ended: ${auction.schedule.date}", style: const TextStyle(color: Colors.white70, fontSize: 13,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    });
  }
}
