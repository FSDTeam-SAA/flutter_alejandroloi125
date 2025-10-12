import 'package:flutter/material.dart';

class Auctions {
  final String imageUrl;
  final String title;
  final double currentPrice;
  final int viewers;
  const Auctions({
    required this.imageUrl,
    required this.title,
    required this.currentPrice,
    required this.viewers,
  });
}

class LiveAuctionCards extends StatelessWidget {
  const LiveAuctionCards({
    super.key,
    required this.auction,
    required this.onTap,
  });

  final Auctions auction;
  final VoidCallback onTap;

  static const _cardBg = Color(0xFF1A1B1E);
  static const _liveRed = Color(0xFFFF4D4F);
  static const _chipBg = Color(0xE61F2023);
  static const _chipBorder = Color(0x33FFFFFF);

  bool get _isNetwork =>
      auction.imageUrl.startsWith('http://') ||
      auction.imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final priceColor = Theme.of(context).colorScheme.primary;

    // Keep total height < 200:
    //  image 118 + text area ~60–70 = < 190
    const double _imageH = 118;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                height: _imageH,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _isNetwork
                        ? Image.network(
                            auction.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _errorImage(),
                            loadingBuilder: (c, child, l) =>
                                l == null ? child : _loading(),
                          )
                        : Image.asset(
                            auction.imageUrl.isEmpty
                                ? 'assets/images/tree.jpg'
                                : auction.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _errorImage(),
                          ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x33000000),
                            Color(0x66000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5, // was 6
                        ),
                        decoration: BoxDecoration(
                          color: _liveRed,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, size: 9, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5, // was 4
                        ),
                        decoration: BoxDecoration(
                          color: _chipBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _chipBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility, size: 13.5, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${auction.viewers}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title & price (tightened paddings to fit)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // was 12,10,12,12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${auction.currentPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 172, 111, 54),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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

  Widget _loading() => Container(
        color: const Color(0x11000000),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );

  Widget _errorImage() => Container(
        color: const Color(0x11000000),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 28,
          color: Colors.white70,
        ),
      );
}
