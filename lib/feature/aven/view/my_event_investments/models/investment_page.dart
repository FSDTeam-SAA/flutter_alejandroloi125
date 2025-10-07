
import '../../../../models/investment.dart';

class InvestmentPage {
  final int total;
  final int page;
  final int limit;
  final int pages;
  final List<Investment> items;

  const InvestmentPage({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.items,
  });
}
