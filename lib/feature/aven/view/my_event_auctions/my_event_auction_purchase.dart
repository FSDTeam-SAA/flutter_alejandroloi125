import 'package:flutter/material.dart';

// ======= Palette (kept consistent with your detail screen) =======
const _bg = Color(0xFF2B2B2E);
const _card = Color(0xFF1E1F22);
const _pillGreen = Color(0xFF2AA86F);
const _accent = Color(0xFFFF7A00);

class MyEventAuctionPurchase extends StatefulWidget {
  const MyEventAuctionPurchase({super.key});

  @override
  State<MyEventAuctionPurchase> createState() => _AuctionPurchaseScreenState();
}

class _AuctionPurchaseScreenState extends State<MyEventAuctionPurchase> {
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController expCtrl = TextEditingController();
  final TextEditingController cvvCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController(text: 'John Doe');
  bool savePayment = false;

  @override
  void dispose() {
    cardNumberCtrl.dispose();
    expCtrl.dispose();
    cvvCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const total = 1240; // 1200 + 25 + 15

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Custom Header ----------
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Auctions Purchase',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ---------- Win Banner ----------
              const Text(
                'Auction Won!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Opacity(
                opacity: 0.85,
                child: Text(
                  'Complete your purchase to claim your item.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),

              // ---------- Product Card ----------
              Container(
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/earpod.jpg', width: 64, height: 64, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Gaming Console', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 6),
                          _KeyValueRow(k: 'First Bid:', v: '\$500'),
                          _KeyValueRow(k: 'Final Bid:', v: '\$1,200', accent: true),
                          SizedBox(height: 6),
                          _EndedRow(text: 'Ended jun 10'),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Shipping Address ----------
              const _SectionTitle('Shipping Address', sub: 'Where should we send your item?'),
              const SizedBox(height: 8),
              const _AddressBlock(
                name: 'Alex Johnson',
                line1: '123 Main Street, Apt 4B',
                line2: 'New York, NY 10001',
                country: 'United States',
              ),

              const SizedBox(height: 18),

              // ---------- Payment ----------
              const _SectionTitle('Card Number'),
              const SizedBox(height: 6),
              _FilledInput(hint: '1234 5678 9012 3456', controller: cardNumberCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Expiry Date'),
                        const SizedBox(height: 6),
                        _FilledInput(hint: 'MM/YY', controller: expCtrl),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('CVV'),
                        const SizedBox(height: 6),
                        _FilledInput(hint: '123', controller: cvvCtrl),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _SectionTitle('Name on Card'),
              const SizedBox(height: 6),
              _FilledInput(hint: 'John Doe', controller: nameCtrl),
              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: savePayment,
                    onChanged: (v) => setState(() => savePayment = v ?? false),
                    fillColor: MaterialStateProperty.resolveWith((_) => Colors.white30),
                    checkColor: Colors.white,
                  ),
                  const Expanded(
                    child: Text(
                      'Save payment details for future purchases',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ---------- Saved cards ----------
              const _SavedCardTile(brand: 'VISA', masked: '651***********643791'),
              const SizedBox(height: 8),
              const _SavedCardTile(brand: 'MASTERCARD', masked: '454***********148476'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.credit_card),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Add New Card'),
                    CircleAvatar(radius: 9, backgroundColor: _accent, child: Icon(Icons.add, size: 14, color: Colors.white)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Order Summary ----------
              const _SectionTitle('Order Summary'),
              const SizedBox(height: 10),
              const _SummaryRow('Winning Bid:', '\$1200'),
              const _SummaryRow('Service Fee:', 'Free'),
              const _SummaryRow('Shipping:', '\$25'),
              const _SummaryRow('Tax:', '\$15'),
              const Divider(color: Colors.white12, height: 20, thickness: 1),
              const _SummaryRow('Total:', '\$1240', bold: true),
              const SizedBox(height: 14),

              // Terms/Info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accent.withOpacity(.6), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: _accent, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'By completing this purchase, you agree to our Terms of Service and confirm that the item meets your expectations.',
                        style: TextStyle(color: Colors.white, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Pay button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: const Text('Pay \$1240', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======= helpers/widgets =======
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
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String k, v; final bool accent; const _KeyValueRow({required this.k, required this.v, this.accent = false});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(k, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(width: 4),
      Text(v, style: TextStyle(color: accent ? _accent : Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _EndedRow extends StatelessWidget {
  final String text; const _EndedRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.access_time, size: 14, color: Colors.white70),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; final String? sub; const _SectionTitle(this.title, {this.sub});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      if (sub != null) ...[
        const SizedBox(height: 4),
        Text(sub!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]
    ]);
  }
}

class _AddressBlock extends StatelessWidget {
  final String name, line1, line2, country; const _AddressBlock({required this.name, required this.line1, required this.line2, required this.country});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(line1, style: const TextStyle(color: Colors.white)),
      Text(line2, style: const TextStyle(color: Colors.white)),
      Text(country, style: const TextStyle(color: Colors.white)),
    ]);
  }
}

class _FilledInput extends StatelessWidget {
  final String hint; final TextEditingController controller; const _FilledInput({required this.hint, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2B2C30),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  final String brand; final String masked; const _SavedCardTile({required this.brand, required this.masked});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, size: 20, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$brand  $masked',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.check_circle, size: 18, color: Colors.white38),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String k, v; final bool bold; const _SummaryRow(this.k, this.v, {this.bold = false});
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.white, fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: style.copyWith(fontWeight: FontWeight.w600))),
          Text(v, style: style),
        ],
      ),
    );
  }
}
