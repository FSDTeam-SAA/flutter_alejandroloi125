import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/investment_provider.dart';
import 'my_event_investment.dart';


class MyEventInvestmentTab extends StatefulWidget {
  final String userId; // <-- same id you use in Postman
  const MyEventInvestmentTab({super.key, required this.userId});

  @override
  State<MyEventInvestmentTab> createState() => _MyEventInvestmentTabState();
}

class _MyEventInvestmentTabState extends State<MyEventInvestmentTab> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      _fetched = true;
      context
          .read<InvestmentProvider>()
          .fetchByUser(userId: widget.userId, page: 1, limit: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InvestmentProvider>();

    if (prov.loading && prov.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null && prov.items.isEmpty) {
      return Center(
        child: Text(prov.error!, style: const TextStyle(color: Colors.red)),
      );
    }

    return MyEventInvestmentScreen(
      investments: prov.items,                       // <-- feed data in
      onDelete: (it) async =>                       // optional delete hook
      context.read<InvestmentProvider>().delete(it.id),
    );
  }
}
