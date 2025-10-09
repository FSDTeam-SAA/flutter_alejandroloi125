// // lib/feature/investment/providers/my_investments_provider.dart
// import 'package:flutter/foundation.dart';
// import '../../../repository/investment_repository.dart';
// import '../models/investment_list_item.dart';
//
// class MyInvestmentsProvider extends ChangeNotifier {
//   final InvestmentRepository repo;
//   MyInvestmentsProvider(this.repo);
//
//   bool loading = false;
//   String? error;
//   final List<InvestmentListItem> items = [];
//
//   PageMeta? meta;
//   int _page = 1;
//   final int _limit = 10;
//   bool get hasMore => meta != null && _page < meta!.pages;
//
//   Future<void> loadFirst() async {
//     loading = true; error = null; notifyListeners();
//     try {
//       _page = 1; items.clear();
//       final res = await repo.getAll(page: _page, limit: _limit);
//       // items.addAll(res.items);
//       // meta = res.meta;
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       loading = false; notifyListeners();
//     }
//   }
//
//   Future<void> refresh() => loadFirst();
//
//   Future<void> loadMore() async {
//     if (!hasMore || loading) return;
//     loading = true; notifyListeners();
//     try {
//       _page += 1;
//       final res = await repo.getAll(page: _page, limit: _limit);
//       // items.addAll(res.items);
//       // meta = res.meta;
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       loading = false; notifyListeners();
//     }
//   }
// }
