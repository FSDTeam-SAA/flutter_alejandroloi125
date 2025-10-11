// lib/invest_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_service/api_client.dart';
import '../../core/network/payment_service.dart';
import '../../providers/investment_provider.dart';
import '../auth/providers/auth_provider.dart';
import '../models/investment.dart';

class InvestScreen extends StatefulWidget {
  final String investmentId;          // passed from details
  final String? investmentTitle;      // optional title from details

  const InvestScreen({
    super.key,
    required this.investmentId,
    this.investmentTitle,
  });

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  bool agree = false;

  final _amountCtrl = TextEditingController();
  bool _paying = false;

  Investment? _inv;
  bool _loading = true;
  String? _error;

  // ---------- NEW: helpers ----------
  static const int _fallbackMin = 1000;

  int get _minInvestment => 1000;

  int get _typedAmount {
    final t = _amountCtrl.text.trim();
    return int.tryParse(t.isEmpty ? '0' : t) ?? 0;
  }

  bool get _canPay => agree && _typedAmount >= _minInvestment && !_paying;

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
  // -----------------------------------

  @override
  void initState() {
    super.initState();
    _load();
    // Rebuild totals & button label as user types
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final inv = await context.read<InvestmentProvider>().getById(widget.investmentId);
      if (!mounted) return;
      setState(() {
        _inv = inv;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _startPayment() async {
    if (_paying) return;

    if (!agree) {
      Get.snackbar('Agreement required', 'Please accept the terms to continue',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final amount = _typedAmount; // <<< dynamic amount
    if (amount < _minInvestment) {
      Get.snackbar(
        'Amount too low',
        'Minimum investment is ${_money(_minInvestment)}',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _paying = true);
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.id;
      if (userId == null || userId.isEmpty) {
        Get.snackbar('Login required', 'Please sign in to continue',
            snackPosition: SnackPosition.TOP);
        setState(() => _paying = false);
        return;
      }

      final dio = context.read<ApiClient>().dio;
      final payment = PaymentService(dio);

      final clientSecret = await payment.createPaymentIntent(
        userId: userId,
        investmentId: widget.investmentId,
        amount: amount,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'AlejandroLoi',
          style: ThemeMode.dark,
          primaryButtonLabel: 'Invest ${_money(amount)}',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final txId = clientSecret.split('_secret').first; // "pi_xxx"
      await payment.confirmPayment(paymentIntentId: txId);

      Get.snackbar('Success', 'Payment completed',
          snackPosition: SnackPosition.TOP);
    } on StripeException catch (e) {
      final canceled = e.error.code == FailureCode.Canceled;
      final title = canceled ? 'Cancelled' : 'Stripe error';
      final msg = e.error.localizedMessage ?? (canceled ? 'Payment cancelled' : 'Payment failed');
      Get.snackbar(title, msg, snackPosition: SnackPosition.TOP);
    } on DioException catch (e) {
      String message = e.message ?? 'Request failed';
      final data = e.response?.data;

      if (data != null) {
        if (data is Map) {
          message = (data['message'] ??
              data['error'] ??
              data['detail'] ??
              (data['errors']?.toString()) ??
              message).toString();
        } else if (data is String && data.trim().isNotEmpty) {
          message = data;
        }
      }

      Get.snackbar('Error', message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F0F12);
    const card = Color(0xFF1B1E23);
    const accent = Color(0xFFFF7A1A);

    final title = widget.investmentTitle ??
        ((_inv?.name.isNotEmpty ?? false) ? _inv!.name : 'Urban Farming Initiative');

    final pctNum = (_inv?.progressPct ?? 45).clamp(0, 100);
    final pct = pctNum.toDouble();

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
            onPressed: Get.back,
          ),
          title: const Text('Invest'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // HEADER CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _loading ? 'Loading…' : title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _loading ? 0.0 : (pct / 100.0),
                      backgroundColor: Colors.white.withOpacity(.10),
                      color: accent,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _loading ? '—% funded' : '${pct.round()}% funded',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.7)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text('Investment Amount',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
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
            // DYNAMIC MIN
            Text(
              'Minimum investment: ${_money(_minInvestment)}',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.6)),
            ),
            const SizedBox(height: 16),

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

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Investment involves risk. The value of your investment may rise or fall and your capital is at risk.',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DYNAMIC TOTAL
            Row(
              children: [
                const Text('Total Investment:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text(
                  _money(_typedAmount),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DYNAMIC BUTTON
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _canPay ? _startPayment : null,
                style: TextButton.styleFrom(
                  backgroundColor: _canPay ? accent : Colors.white12,
                  foregroundColor: _canPay ? Colors.black : Colors.white60,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Invest ${_money(_typedAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
