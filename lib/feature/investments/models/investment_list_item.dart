// lib/feature/investment/models/investment_list_item.dart
class PageMeta {
  final int total, page, limit, pages;
  const PageMeta({required this.total, required this.page, required this.limit, required this.pages});

  factory PageMeta.fromJson(Map<String, dynamic> j) => PageMeta(
    total: (j['total'] ?? 0) as int,
    page:  (j['page']  ?? 1) as int,
    limit: (j['limit'] ?? 10) as int,
    pages: (j['pages'] ?? 1) as int,
  );
}

class InvestmentListItem {
  final String id;
  final String? name, description, category, status, location;
  final int? fundingGoal, progressPct, daysLeft;
  final String? imageUrl;

  const InvestmentListItem({
    required this.id,
    this.name,
    this.description,
    this.category,
    this.status,
    this.location,
    this.fundingGoal,
    this.progressPct,
    this.daysLeft,
    this.imageUrl,
  });

  factory InvestmentListItem.fromJson(Map<String, dynamic> j) {
    String? firstImage(dynamic v) {
      if (v is List && v.isNotEmpty) {
        final a = v.first;
        if (a is Map && a['url'] != null) return a['url'].toString();
        if (a is String) return a;
      }
      if (v is Map && v['url'] != null) return v['url'].toString();
      if (v is String) return v;
      return null;
    }

    return InvestmentListItem(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      category: (j['category'] is List && (j['category'] as List).isNotEmpty)
          ? (j['category'] as List).first.toString()
          : (j['category']?.toString() ?? ''),
      status: (j['status'] ?? 'In Progress').toString(),
      location: (j['location'] ?? '').toString(),
      fundingGoal: (j['funding_goal'] is num)
          ? (j['funding_goal'] as num).toInt()
          : int.tryParse('${j['funding_goal']}'),
      progressPct: int.tryParse('${j['progress'] ?? j['progressPct'] ?? 0}') ?? 0,
      daysLeft: int.tryParse('${j['daysLeft'] ?? 0}') ?? 0,
      imageUrl: firstImage(j['imageLink'] ?? j['image'] ?? j['images']),
    );
  }
}
