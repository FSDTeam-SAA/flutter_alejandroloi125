// lib/invest_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../project/view/project.dart' show ProjectScreen;

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  bool saveCard = false;
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F0F12);
    const card = Color(0xFF1B1E23);
    const inner = Color(0xFF23262B);
    const accent = Color(0xFFFF7A1A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: card,
        ),
      ),
      home: Scaffold(

        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () {},
          ),
          title: const Text('Invest'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // project box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Urban Farming Initiative',
                      style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: Colors.white.withOpacity(.1),
                      color: accent,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('45% funded',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(.7))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // amount
            const Text('Investment Amount',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(CupertinoIcons.money_dollar),
                hintText: 'Enter your Price',
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('Minimum investment: \$1000',
                style:
                TextStyle(fontSize: 12, color: Colors.white.withOpacity(.6))),
            const SizedBox(height: 16),

            // card fields
            const TextField(
              decoration: InputDecoration(
                hintText: 'Card Number',
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'MM/YY',
                      filled: true,
                      fillColor: card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'CVV',
                      filled: true,
                      fillColor: card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Name on Card',
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // save option
            Row(
              children: [
                Checkbox(
                  value: saveCard,
                  onChanged: (v) => setState(() => saveCard = v!),
                  activeColor: accent,
                ),
                const Expanded(
                  child: Text('Save payment details for future purchases',
                      style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // saved cards
            _SavedCardRow(
              logo: Icons.credit_card,
              number: '651***********643791',
            ),
            const SizedBox(height: 8),
            _SavedCardRow(
              logo: Icons.credit_card,
              number: '454***********148476',
            ),
            const SizedBox(height: 10),

            // add new card
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: inner,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: accent),
                    const SizedBox(width: 8),
                    const Text('Add New Card',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: accent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // agree checkbox
            Row(
              children: [
                Checkbox(
                  value: agree,
                  onChanged: (v) => setState(() => agree = v!),
                  activeColor: accent,
                ),
                const Expanded(
                  child: Text(
                    'I agree to the investment terms and conditions, including the risks associated with this investment.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // warning box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Investment involves risk. The value of your investment may rise or fall and your capital is at risk.',
                      style:
                      const TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // total
            Row(
              children: const [
                Text('Total Investment:',
                    style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Spacer(),
                Text('\$1000',
                    style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),

            // invest button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.to(ProjectScreen());
                },
                style: TextButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Invest \$1000',
                    style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCardRow extends StatelessWidget {
  final IconData logo;
  final String number;
  const _SavedCardRow({required this.logo, required this.number});

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF1B1E23);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(logo, color: Colors.white),
          const SizedBox(width: 12),
          Text(number,
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
