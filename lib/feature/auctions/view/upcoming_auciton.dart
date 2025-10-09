import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auction_controller.dart';
import '../model/auction_model.dart';
import 'auction_detail.dart';

class UpcomingAuctionTile extends StatelessWidget {
  const UpcomingAuctionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuctionController>();
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.error.value.isNotEmpty) {
        return Center(child: Text(controller.error.value));
      } else if (controller.upcomingAuctions.isEmpty) {
        return const Center(child: Text('No upcoming auctions'));

      }   else if (controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.error.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  //controller.fetchUpcomingAuctions(); // 🔁 আবার API কল
                },
                child: const Text("Try Again"),
              ),
            ],
          ),
        );
      }
      else {
        return ListView.builder(
          itemCount: controller.upcomingAuctions.length,
          itemBuilder: (_, index) {
            final auction = controller.upcomingAuctions[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){

                  // Navigate and pass the auction object

                  Get.to(() => AuctionDetailPage(),
                    arguments: {
                    "name": auction.name,
                      "description": auction.description,
                      "startingBid": auction.startingBid,
                      "endingBid": auction.createdAt,
                      "image": auction.image[0].url,
                      "schedule": auction.schedule,
                      "auctionId": auction.id,
                      "currentBid": auction.startingBid,
                      "price":"${auction.startingBid}"

                    },
                  );



                },
                child: Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: auction.image.isNotEmpty ? Image.network(
                          auction.image[0].url, width: 108,height: 108, fit: BoxFit.cover,) :
                        Container(
                          width: 108, height: 108,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 108,),
                        ),
                      ),

                      SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        SizedBox(
                          width: 200,
                          child: Text(auction.name, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white,),  ),
                        ),
                      Row(
                        children: [
                          Text("First Bid : "),
                          Text("\$ ${auction.startingBid}",style: TextStyle(color: AppColors.bottomColor1),)
                        ],
                      ),
                          Row(
                        children: [
                          Text("Final Bid : "),
                          Text("\$ ${auction.startingBid}",style: TextStyle(color: AppColors.bottomColor1),)
                        ],
                      ),

                      Row(
                        children: [
                          Icon(Icons.watch_later_outlined),
                          Text(" Ends :${auction.schedule.date}"),
                        ],
                      ),
                      //Text(auction.endDate.toString()),
                      //  Text(auction.description),
                        //Text(auction.startingBid.toString()),
                      ],)
                    ],
                  ),

                  /*ListTile(
                    leading: auction.image.isNotEmpty
                        ? Image.network(
                      auction.image[0].url,
                      width: 60,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image_not_supported),
                    title: Text(
                      auction.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      auction.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      '\$${auction.startingBid}',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),*/
                            ),
              ));
          },
        );
      }
    });
  }
}
