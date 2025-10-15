import 'package:get/get.dart';

import '../../aven/view/my_event_auctions/my_event_auction.dart';
import '../model/auction_model.dart';
import '../model/chat_model.dart';
import '../repo/auction_repo.dart';

class AuctionController extends GetxController {
  final AuctionRepository repository;
  AuctionController(this.repository){
    
  }

  var allAuctions = <AuctionItem>[].obs;
  var liveAuctions = <AuctionItem>[].obs;
  var upcomingAuctions = <AuctionItem>[].obs;
  var endedAuctions = <AuctionItem>[].obs;
  var auctionChat = Rxn<ChatResponse>();

  var loading = false.obs;
  var error = ''.obs;

  var currentAuctionId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAuctions();

    print("AuctionController initialized");
    // if (currentAuctionId.isNotEmpty) {
    //   loadAuctionChat(currentAuctionId.value);
    // }

    // ever(currentAuctionId, (String auctionId) {
    //   if (auctionId.isNotEmpty) {
    //     loadAuctionChat(auctionId);
    //   }
    // });


  }

  Future<void> loadAuctions() async {
    try {
      loading.value = true;
      error.value = '';
      final auctionModel = await repository.getAuctions();

      allAuctions.assignAll(auctionModel.data.auctions);

      // status অনুযায়ী filter
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

  Future<void> loadAuctionChat(String auctionId) async {
    print("Loading chat for auctionId: $auctionId"); // debug
    try {
      loading.value = true;
      error.value = '';
      auctionChat.value = await repository.getAuctionChat(auctionId);
      print("Chat loaded: ${auctionChat.value?.data.length} messages"); // debug
    } catch (e) {
      error.value = e.toString();
      print("********************Chat error: $e"); // debug
    } finally {
      loading.value = false;
    }
  }
}
