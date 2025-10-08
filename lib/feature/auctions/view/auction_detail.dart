import 'dart:async';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuctionDetailPage extends StatefulWidget {
  const AuctionDetailPage({super.key});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  late final DateTime endTime;
  late final Stream<String> timer$;
  final bidCtrl = TextEditingController(text: '1250+');
  final msgCtrl = TextEditingController();

  final List<String> auctionMessages = [];
  final TextEditingController messageCtrl = TextEditingController();



  final List<ChatMessage> messages = [
    ChatMessage(name: 'Ronald Richards', avatar: 'https://i.pravatar.cc/100?img=14', timeAgo: '2m ago', text: r'$500'),
    ChatMessage(name: 'Arlene McCoy', avatar: 'https://i.pravatar.cc/100?img=36', timeAgo: '2m ago', text: r'$600'),
    ChatMessage(name: 'Darrell Stewart', avatar: 'https://i.pravatar.cc/100?img=22', timeAgo: '2m ago', text: "What's the band material?"),
    ChatMessage(name: 'Kathryn Murphy', avatar: 'https://i.pravatar.cc/100?img=57', timeAgo: '2m ago', text: r'$1000'),
    ChatMessage(name: 'Devon Lane', avatar: 'https://i.pravatar.cc/100?img=47', timeAgo: '2m ago', text: 'Beautiful !'),
    ChatMessage(name: 'Robert Fox', avatar: 'https://i.pravatar.cc/100?img=33', timeAgo: '2m ago', text: "I'll go \$1,200"),
    ChatMessage(name: 'Darlene Robertson', avatar: 'https://i.pravatar.cc/100?img=4', timeAgo: '2m ago', text: r'$1250'),
  ];

  late String auctionName;
  late String auctionDescription;
  late String auctionImage;
  late String auctionPrice;
  late String auctionEndDate;


  @override
  void initState() {
    super.initState();

    // Countdown ~3 minutes from now
    endTime = DateTime.now().add(const Duration(minutes: 3));
    timer$ = Stream.periodic(const Duration(seconds: 1), (_) {
      final diff = endTime.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final m = diff.inMinutes.remainder(60).toString().padLeft(1, '0');
      final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    });

    // Parse Get.arguments safely
    final args = Get.arguments as Map<String, dynamic>;
    auctionName = args['name'] ?? 'Auction';
    auctionDescription = args['description'] ?? '';
    auctionImage = args['image']??'';
   /// auctionImage = args['image'] ?? '';
    auctionPrice = args['price'] ?? '';
    //auctionEndDate = args['endDate'] ?? '';
    print("pric:$auctionPrice");
  }

  @override
  void dispose() {
    bidCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  void _placeBid() {
    FocusScope.of(context).unfocus();
    final raw = bidCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) {
      _toast('Enter a valid bid');
      return;
    }
    _toast('Bid placed: \$$raw');
  }

  void _sendMessage() {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(ChatMessage(
        name: 'You',
        avatar: 'https://i.pravatar.cc/100?img=1',
        timeAgo: 'now',
        text: text,
      ));
    });
    msgCtrl.clear();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    print("pric:$auctionPrice");

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======= Collapsing header with image =======
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(auctionImage, fit: BoxFit.cover,),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Color(0x33000000), Color(0x99000000),],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8, right: 8,
                    child: Row(
                      children: [
                        _circleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Get.back(),),
                        const Spacer(), _circleBtn(icon: Icons.favorite_border_rounded, onTap: () {}),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 56),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 10, color: Colors.white),
                          SizedBox(width: 6),
                          Text('LIVE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10, left: 12, right: 12,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                auctionName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,color: Colors.white),
                              ),
                            ),
                            const Text('@eleanorpena', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),
                        const Spacer(),
                        _metricChip(Icons.visibility, '142'),
                        const SizedBox(width: 6),
                        _metricChip(Icons.favorite, '86'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ======= Body =======
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Text(auctionDescription, style: TextStyle(color: Colors.white.withOpacity(0.75))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Bid',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),


                          auctionPrice.isEmpty? SizedBox(
                              width: 100,
                              child: Text("\$ 0",style: TextStyle(color: Colors.white),overflow: TextOverflow.ellipsis,)):
                             Text(auctionPrice,style: TextStyle(color: Colors.white),overflow: TextOverflow.ellipsis,),

                        ],
                      ),

                     // const SizedBox(width: 10),
                    Spacer(),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: bidCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.black, // TextField background
                            hintText: '1250+',
                            hintStyle: const TextStyle(color: Colors.grey), // default hint color
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white), // unfocused border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white), // focused border
                            ),
                          ),
                          style: const TextStyle(color: Colors.white), // input text color
                        ),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: _placeBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bottomColor1,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Bid', style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_outlined,color: Colors.white,),
                        SizedBox(width: 8,),
                        Text("Live Chat",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 16),),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                    color: const Color(0xFF0F0F10),
                    //  color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.black
                          //color: Theme.of(context).dividerColor
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 16, backgroundImage: NetworkImage(m.avatar)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    children: [
                                      Expanded(child: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700,color: Colors.white))),
                                      Text(m.timeAgo, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(m.text, style: const TextStyle(height: 1.25,color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F10),
              //color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
          child: Row(
            children: [
              Expanded(
              child:   TextField(
                  controller: messageCtrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0F0F10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),


                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1.2),
                    ),


                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),


                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),

              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                width: 56,
                child:
                ElevatedButton(
                  onPressed: () {
                    if (messageCtrl.text.isNotEmpty) {
                      setState(() {
                        auctionMessages.add(messageCtrl.text);
                        messageCtrl.clear();
                      });
                    }
                    print("========================$auctionMessages");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bottomColor1,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),


                /*    ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bottomColor1,
                      //backgroundColor: cs.primary,
                      foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.zero),
                  child: const Icon(Icons.send_rounded,color: Colors.white,),
                ),*/
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Helpers & Models =====
Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0x40000000), shape: BoxShape.circle, border: Border.all(color: const Color(0x55FFFFFF))),
      child: Icon(icon, size: 20,color: Colors.white,),
    ),
  );
}

Widget _metricChip(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x55FFFFFF))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16,color: Colors.white,),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700,color: Colors.white)),
      ],
    ),
  );
}

class ChatMessage {
  final String name;
  final String avatar;
  final String timeAgo;
  final String text;

  ChatMessage({
    required this.name,
    required this.avatar,
    required this.timeAgo,
    required this.text,
  });
}
