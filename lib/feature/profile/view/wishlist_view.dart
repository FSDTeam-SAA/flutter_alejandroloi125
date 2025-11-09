import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/language/language_controller.dart';

// ---- palette (match your app) ----
const _bg = Color(0xFF0B0B0B);
const _card = Color(0xFF1E1F22);
const _stroke = Color(0x22FFFFFF);
const _text = Colors.white;
const _subtext = Colors.white70;
const _accent = Color(0xFFFF7A00); // primary accent (orange)

class WishlistViewScreen extends StatefulWidget {
  const WishlistViewScreen({super.key});

  @override
  State<WishlistViewScreen> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistViewScreen> {
  final List<_WishItem> _items = [
    _WishItem(
      id: '1',
      title: 'Gaming Console',
      price: 499.00,
      image: 'assets/images/diamond.jpg',
    ),
    _WishItem(
      id: '2',
      title: 'Wireless Headphones',
      price: 199.00,
      image: 'assets/images/earpod.jpg',
    ),
    _WishItem(
      id: '3',
      title: 'Smart Watch Series X',
      price: 299.00,
      image: 'assets/images/watch.jpg',
    ),
  ];

  final Set<String> _moving = {}; // loading states for "Move to Cart"

  @override
  Widget build(BuildContext context) {
    final languageController = Get.put(LanguageController());
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: _BackCircle(onTap: () => Navigator.pop(context)),
        title: Text(
          languageController.t('wish_list'),
          style: TextStyle(
            color: _text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: _items.isEmpty ? _EmptyState(onExplore: _onExplore) : _list(),
    );
  }

  Widget _list() {
    final languageController = Get.put(LanguageController());
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _items[index];

        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: _dismissBg(),
          onDismissed: (_) => setState(() => _items.removeAt(index)),
          child: Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _stroke),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // text + buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // price
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // actions row
                      Row(
                        children: [
                          // Move to cart
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _moving.contains(item.id)
                                    ? null
                                    : () async {
                                        setState(() => _moving.add(item.id));
                                        await Future.delayed(
                                          const Duration(milliseconds: 600),
                                        );
                                        setState(() {
                                          _moving.remove(item.id);
                                          _items.remove(item);
                                        });
                                        // TODO: actually move to cart in your app state
                                      },
                                child: _moving.contains(item.id)
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        languageController.t('move_to_cart'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // remove (heart off)
                          _IconButtonPill(
                            icon: CupertinoIcons.heart_slash,
                            onTap: () => setState(() => _items.remove(item)),
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

  Widget _dismissBg() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(CupertinoIcons.delete_solid, color: Colors.white),
    );
  }

  void _onExplore() {
    // Navigate to a discovery/browse screen
    Navigator.pop(context); // or push to your Explore page
  }
}

// ---------- Models ----------
class _WishItem {
  final String id;
  final String title;
  final double price;
  final String image;

  _WishItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });
}

// ---------- Small UI pieces ----------
class _BackCircle extends StatelessWidget {
  const _BackCircle({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(CupertinoIcons.back, color: _text, size: 20),
        ),
      ),
    );
  }
}

class _IconButtonPill extends StatelessWidget {
  const _IconButtonPill({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 40,
          child: Icon(icon, color: _text, size: 18),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.heart, color: _subtext, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Your wishlist is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save items you love and move them to cart anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _subtext),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _accent),
                  foregroundColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onExplore,
                child: const Text(
                  'Explore Items',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- optional: right->left route helper (match the rest of your app) ----
Route wishlistRightToLeft(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
