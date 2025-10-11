import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';            // ⬅️ Add this

import '../../../../core/network/payment_service.dart';
import '../../../../feature/auth/providers/auth_provider.dart';

const _bg = Color(0xFF2B2B2E);
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _input = Color(0xFF2B2C30);

class MyEventAuctionPurchase extends StatefulWidget {
  const MyEventAuctionPurchase({
    super.key,
    required this.auctionId,
    required this.amount, // base winning bid, e.g. 1200
    this.imageUrl,
    this.itemTitle,
  });

  final String auctionId;
  final int amount;
  final String? imageUrl;
  final String? itemTitle;

  @override
  State<MyEventAuctionPurchase> createState() => _MyEventAuctionPurchaseState();
}

class _MyEventAuctionPurchaseState extends State<MyEventAuctionPurchase> {
  bool _paying = false;

  // demo extras
  static const int _shipping = 25;
  static const int _tax = 15;

  int get _total => widget.amount + _shipping + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context, rootNavigator: true).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Auctions Purchase',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text('Auction Won!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Opacity(
                    opacity: .85,
                    child: Text(
                      'Complete your purchase to claim your item.',
                      style: TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product summary
                  Container(
                    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _SafeImage(
                            url: widget.imageUrl,
                            assetFallback: 'assets/images/earpod.jpg',
                            width: 64,
                            height: 64,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.itemTitle ?? 'Winning Item',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              _KVRow(label: 'Final Bid:', value: _money(widget.amount), valueAccent: true),
                              const SizedBox(height: 6),
                              const _EndedWhen('Ended recently'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Summary
                  const _SectionHeader('Order Summary'),
                  const SizedBox(height: 8),
                  _SummaryRow('Winning Bid:', _money(widget.amount)),
                  _SummaryRow('Shipping:', _money(_shipping)),
                  _SummaryRow('Tax:', _money(_tax)),
                  const Divider(height: 20, thickness: 1, color: Colors.white12),
                  _SummaryRow('Total:', _money(_total), bold: true),

                  const SizedBox(height: 14),

                  // Terms
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accent),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline, color: _accent, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'By completing this purchase, you agree to our Terms of Service.',
                            style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pay Button
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _paying ? null : _pay,
                      child: Text('Pay ${_money(_total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            if (_paying)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      // 1) Who pays?
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.id ?? '';
      if (userId.isEmpty) {
        if (!mounted) return;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Please sign in to continue')),
        // );

        Get.snackbar('Error','Please sign in to continue',
            snackPosition: SnackPosition.TOP);

        return;
      }

      // 2) Create intent on backend
      final payment = context.read<PaymentService>();
      final clientSecret = await payment.createPaymentIntent(
        userId: userId,
        // Backend param is "investmentId" in your service — we pass auction id here
        investmentId: widget.auctionId,
        amount: _total,
      );

      // 3) Show Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'AlejandroLoi',
          style: ThemeMode.dark,
          primaryButtonLabel: 'Pay ${_money(_total)}',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 4) Confirm on backend (expects paymentIntentId, not client_secret)
      final intentId = _extractIntentId(clientSecret); // pi_xxx
      await payment.confirmPayment(paymentIntentId: intentId);

      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Payment successful')),
      // );

      Get.snackbar('success','Payment successful',
          snackPosition: SnackPosition.TOP);

      Navigator.of(context, rootNavigator: true).pop();
    } on StripeException catch (e) {
      final canceled = e.error.code == FailureCode.Canceled;
      final message = e.error.localizedMessage ?? (canceled ? 'Payment cancelled' : 'Payment failed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  String _extractIntentId(String clientSecret) {
    final idx = clientSecret.indexOf('_secret');
    return idx == -1 ? clientSecret : clientSecret.substring(0, idx);
  }
}

/// ---- Safe image (network with asset fallback) ----
class _SafeImage extends StatelessWidget {
  const _SafeImage({
    required this.url,
    required this.assetFallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final String assetFallback;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.trim().isNotEmpty) {
      return Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Image.asset(assetFallback, width: width, height: height, fit: fit),
        loadingBuilder: (c, child, prog) =>
        (prog == null)
            ? child
            : SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Image.asset(assetFallback, width: width, height: height, fit: fit);
  }
}

/// ---- Small UI helpers ----
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(18)),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label, value;
  final bool valueAccent;
  const _KVRow({required this.label, required this.value, this.valueAccent = false});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(width: 4),
      Text(
        value,
        style: TextStyle(color: valueAccent ? _accent : Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ]);
  }
}

class _EndedWhen extends StatelessWidget {
  final String text;
  const _EndedWhen(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.access_time, size: 14, color: Colors.white70),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? sub;
  const _SectionHeader(this.title, {this.sub});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
      if (sub != null) ...[
        const SizedBox(height: 4),
        Text(sub!, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
      ],
    ]);
  }
}

class _SummaryRow extends StatelessWidget {
  final String left, right;
  final bool bold;
  const _SummaryRow(this.left, this.right, {this.bold = false});
  @override
  Widget build(BuildContext context) {
    final style =
    TextStyle(color: Colors.white, fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(left, style: style)), Text(right, style: style)]),
    );
  }
}

String _money(num n) {
  final s = n.toStringAsFixed(0);
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[i]);
    final left = s.length - i - 1;
    if (left % 3 == 0 && left != 0) b.write(',');
  }
  return '\$$b';
}
