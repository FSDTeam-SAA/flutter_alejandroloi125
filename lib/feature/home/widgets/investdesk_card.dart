// lib/feature/home/widgets/investdesk_card.dart
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';

class InvestDeskCard extends StatelessWidget {
  final String? imagePath;  // can be asset path or http(s) url
  final String? title;
  final String? type;       // e.g., "Agriculture"
  final String? percent;    // e.g., "45"
  final Widget? progressBar;
  final String? price;      // e.g., "25000"

  const InvestDeskCard({
    super.key,
    this.imagePath,
    this.title,
    this.type,
    this.percent,
    this.price,
    this.progressBar,
  });

  // Reliable network placeholder so something ALWAYS shows
  static const String _fallbackNetwork =
      'https://via.placeholder.com/200x200.png?text=Image';

  bool get _isNetwork {
    final p = imagePath?.trim() ?? '';
    return p.startsWith('http://') || p.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final percentText = (percent == null || percent!.isEmpty)
        ? '0% funded'
        : '${percent!.replaceAll('%', '')}% funded';

    final priceText = (price == null || price!.isEmpty) ? '\$ 0' : '\$ $price';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.fieldColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Image (asset or network) ----
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: _buildImage(),
            ),
          ),

          const SizedBox(width: 15),

          // ---- Text/content ----
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
                  if (progressBar != null) ...[
                    const SizedBox(height: 8),
                    progressBar!,
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          percentText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xffA8A8A8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          priceText,
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

  Widget _buildImage() {
    final src = (imagePath == null || imagePath!.trim().isEmpty)
        ? _fallbackNetwork
        : imagePath!.trim();

    if (_isNetwork) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _loader();
        },
        errorBuilder: (_, __, ___) => _fallbackNet(),
      );
    }

    // Asset path → if it fails, show network placeholder
    return Image.asset(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackNet(),
    );
  }

  Widget _loader() => Container(
        color: const Color(0x11000000),
        alignment: Alignment.center,
        child: const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget _fallbackNet() => Image.network(
        _fallbackNetwork,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0x11000000),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 22,
            color: Colors.white70,
          ),
        ),
      );
}
