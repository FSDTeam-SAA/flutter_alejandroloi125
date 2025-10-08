import 'package:flutter/material.dart';
import 'my_event_aution_details.dart';

// ---- palette ----
const _bg = Color(0xFF000000);
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);

class MyEventAuction extends StatelessWidget {
  const MyEventAuction({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: const [
        AuctionItemWidget(
          imageUrl: 'assets/images/diamond.jpg',
          title: 'Gaming Console',
          finalBid: '\$1,200',
          status: 'Won',
          date: 'Ended jun 10',
        ),
        AuctionItemWidget(
          imageUrl: 'assets/images/watch.jpg',
          title: 'Gaming Console',
          finalBid: '\$1,200',
          status: 'Won',
          date: 'Ended jun 10',
        ),
        AuctionItemWidget(
          imageUrl: 'assets/images/earpod.jpg',
          title: 'Gaming Console',
          finalBid: '\$1,200',
          status: 'Live',
          date: 'Ended jun 10',
        ),
        AuctionItemWidget(
          imageUrl: 'assets/images/agriculture.jpg',
          title: 'Gaming Console',
          finalBid: '\$1,200',
          status: 'Loss',
          date: 'Ended jun 10',
        ),
      ],
    );
  }
}

class AuctionItemWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String finalBid;
  final String status;
  final String date;

  const AuctionItemWidget ({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.finalBid,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          _slideRightToLeft(const MyEventAutionDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------- FIXED, NON-DISTORTING THUMBNAIL ----------
            SizedBox(
              width: 110, // matches the mock proportions
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 4, // force consistent crop
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover, // center-crop without stretching
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ---------- TEXT AREA ----------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + status pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: style.fg,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Final Bid: $1,200 (orange amount)
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Final Bid: ',
                          style: TextStyle(color: Colors.white, fontSize: 13.5),
                        ),
                        TextSpan(
                          text: finalBid,
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Ended date row
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 14, color: Colors.white70),
                      SizedBox(width: 6),
                    ],
                  ),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
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



class _StatusStyle {
  final Color bg;
  final Color fg;
  const _StatusStyle(this.bg, this.fg);
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'won':
    // soft green pill with dark green text
      return const _StatusStyle(Color(0x332AA86F), Color(0xFF2AA86F));
    case 'live':
    // solid red pill with white text
      return const _StatusStyle(Color(0xFFE53935), Colors.white);
    case 'loss':
    // solid red pill with white text
      return const _StatusStyle(Color(0xFFE53935), Colors.white);
    default:
      return const _StatusStyle(Color(0x33424242), Colors.white70);
  }
}

// ---- route helper (right -> left) ----
Route _slideRightToLeft(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}





