import 'package:get/get.dart';

import '../model/auction_model.dart';
import '../repo/auction_repo.dart';

class AuctionController extends GetxController {
  final AuctionRepository repository;
  AuctionController(this.repository);

  var allAuctions = <AuctionItem>[].obs;
  var liveAuctions = <AuctionItem>[].obs;
  var upcomingAuctions = <AuctionItem>[].obs;
  var endedAuctions = <AuctionItem>[].obs;



  var loading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAuctions();
  }

  Future<void> loadAuctions() async {
    try {
      loading.value = true;
      error.value = '';
      final auctionModel = await repository.getAuctions();

      allAuctions.assignAll(auctionModel.data.auctions);


      liveAuctions.assignAll(
        allAuctions.where((a) => a.status.toLowerCase() == 'live').toList(),
      );
      upcomingAuctions.assignAll(
        allAuctions.where((a) => a.status.toLowerCase() == 'upcoming').toList(),
      );
      endedAuctions.assignAll(
        allAuctions.where((a) => a.status.toLowerCase() == 'ended').toList(),
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
