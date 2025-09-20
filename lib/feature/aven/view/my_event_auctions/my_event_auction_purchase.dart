import 'package:flutter/material.dart';

import '../event_view.dart';

/// ===== Palette (same family as your detail screen) =====
const _bg = Color(0xFF2B2B2E);
const _card = Color(0xFF1E1F22);
const _accent = Color(0xFFFF7A00);
const _input = Color(0xFF2B2C30);

class MyEventAuctionPurchase extends StatefulWidget {
  const MyEventAuctionPurchase({super.key});

  @override
  State<MyEventAuctionPurchase> createState() => _MyEventAuctionPurchaseState();
}

class _MyEventAuctionPurchaseState extends State<MyEventAuctionPurchase> {
  final cardNumberCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header ----------
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context, rootNavigator: true).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Auctions Purchase',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------- Win title ----------
              const Text(
                'Auction Won!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Opacity(
                opacity: .85,
                child: Text(
                  'Complete your purchase to claim your item.',
                  style: TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
              ),
              const SizedBox(height: 12),

              // ---------- Product summary card ----------
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/earpod.jpg',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Gaming Console',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          _KVRow(label: 'First Bid:', value: '\$500', valueAccent: true),
                          _KVRow(label: 'Final Bid:', value: '\$1,200', valueAccent: true),
                          SizedBox(height: 6),
                          _EndedWhen('Ended jun 10'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Shipping Address ----------
              const _SectionHeader(
                'Shipping Address',
                sub: 'Where should we send your item?',
              ),
              const SizedBox(height: 10),
              const _AddressLines(
                name: 'Alex Johnson',
                line1: '123 Main Street, Apt 4B',
                line2: 'New York, NY 10001',
                country: 'United States',
              ),

              const SizedBox(height: 18),

              // ---------- Card inputs ----------
              const _FieldLabel('Card Number'),
              const SizedBox(height: 6),
              _FilledInput(hint: '1234 5678 9012 3456', controller: cardNumberCtrl),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Expiry Date'),
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
                        const _FieldLabel('CVV'),
                        const SizedBox(height: 6),
                        _FilledInput(hint: '123', controller: cvvCtrl),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const _FieldLabel('Name on Card'),
              const SizedBox(height: 6),
              _FilledInput(hint: 'John Doe', controller: nameCtrl),

              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: savePayment,
                      onChanged: (v) => setState(() => savePayment = v ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor: MaterialStateProperty.resolveWith((_) => Colors.white24),
                      checkColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Save payment details for future purchases',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ---------- Saved cards ----------
              const _SavedCardTile(brand: _Brand.visa, masked: '651***********643791'),
              const SizedBox(height: 8),
              const _SavedCardTile(brand: _Brand.mastercard, masked: '454***********148476'),
              const SizedBox(height: 8),

              // Add new card (outlined)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Row(
                      children: const [
                        Icon(Icons.add_card_outlined, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Add New Card', style: TextStyle(color: Colors.white)),
                        ),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: _accent,
                          child: Icon(Icons.add, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Order Summary ----------
              const _SectionHeader('Order Summary'),
              const SizedBox(height: 8),
              const _SummaryRow('Winning Bid:', '\$1200'),
              const _SummaryRow('Service Fee:', 'Free'),
              const _SummaryRow('Shipping:', '\$25'),
              const _SummaryRow('Tax:', '\$15'),
              const Divider(height: 20, thickness: 1, color: Colors.white12),
              const _SummaryRow('Total:', '\$1240', bold: true),

              const SizedBox(height: 14),

              // ---------- Terms / Note ----------
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
                        'By completing this purchase, you agree to our Terms of Service and confirm that the item meets your expectations.',
                        style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------- Pay Button ----------
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
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

/// ====== Small building blocks ======

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

class _KVRow extends StatelessWidget {
  final String label, value;
  final bool valueAccent;
  const _KVRow({required this.label, required this.value, this.valueAccent = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: valueAccent ? _accent : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EndedWhen extends StatelessWidget {
  final String text;
  const _EndedWhen(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Colors.white70),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? sub;
  const _SectionHeader(this.title, {this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
      ),
      if (sub != null) ...[
        const SizedBox(height: 4),
        Text(sub!, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
      ],
    ]);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600));
  }
}

class _AddressLines extends StatelessWidget {
  final String name, line1, line2, country;
  const _AddressLines({required this.name, required this.line1, required this.line2, required this.country});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(line1, style: const TextStyle(color: Colors.white)),
      Text(line2, style: const TextStyle(color: Colors.white)),
      Text(country, style: const TextStyle(color: Colors.white)),
    ]);
  }
}

class _FilledInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const _FilledInput({required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: _input,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
}

enum _Brand { visa, mastercard }

class _SavedCardTile extends StatelessWidget {
  final _Brand brand;
  final String masked;
  const _SavedCardTile({required this.brand, required this.masked});

  @override
  Widget build(BuildContext context) {
    final brandChip = switch (brand) {
      _Brand.visa => _brandBadge('VISA', const Color(0xFF1A73E8)),
      _Brand.mastercard => _brandBadge('MC', const Color(0xFFEB001B)), // stylized badge
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          brandChip,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              masked,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.white38, size: 18),
        ],
      ),
    );
  }

  Widget _brandBadge(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
    // For MasterCard you can alternatively draw two colored circles if you want:
    // return Row(children:[_circle(0xFFEB001B),_circle(0xFFF79E1B)]);
  }
}

class _SummaryRow extends StatelessWidget {
  final String left, right;
  final bool bold;
  const _SummaryRow(this.left, this.right, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Text(right, style: style),
        ],
      ),
    );
  }
}



