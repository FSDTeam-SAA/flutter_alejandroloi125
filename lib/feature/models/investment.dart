// lib/feature/investment/models/investment.dart
class InvestmentImage {
  final String url;
  final String filename;
  final String publicId;
  const InvestmentImage({required this.url, required this.filename, required this.publicId});

  factory InvestmentImage.fromJson(Map<String, dynamic> j) => InvestmentImage(
    url: (j['url'] ?? j['imageUrl'] ?? j['link'] ?? '').toString(),
    filename: (j['filename'] ?? j['name'] ?? '').toString(),
    publicId: (j['public_id'] ?? j['publicId'] ?? '').toString(),
  );
}

class Investment {
  final String id;
  final String name;
  final String description;
  final List<String> category;
  final int? fundingGoal;
  final String? fundingDuration;
  final String location;
  final String investmentTerms;
  final List<InvestmentImage> images;

  const Investment({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.fundingGoal,
    required this.fundingDuration,
    required this.location,
    required this.investmentTerms,
    required this.images,
  });

  factory Investment.fromJson(Map<String, dynamic> j) {
    List<String> cat(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return const [];
    }

    List<InvestmentImage> imgs(dynamic v) {
      if (v is List) {
        return v.whereType<Map>().map((m) => InvestmentImage.fromJson(Map<String, dynamic>.from(m))).toList();
      }
      return const [];
    }

    int? intOr(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');



    return Investment(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      category: cat(j['category']),
      fundingGoal: intOr(j['funding_goal']),
      fundingDuration: (j['funding_duration'] ?? '').toString(),
      location: (j['location'] ?? '').toString(),
      investmentTerms: (j['investment_terms'] ?? '').toString(),
      // server returns `imageLink` list of objects (preferred), but accept legacy `image`
      // images: imgs(j['imageLink'] ?? j['image']),
      images: imgs(j['imageLink'] ?? j['image'] ?? j['images']),

    );
  }

  String? get primaryImageUrl => images.isNotEmpty ? images.first.url : null;




  int get progressPct {
    // you can compute based on raised/goal later; default 0
    final goal = fundingGoal ?? 0;
    if (goal <= 0) return 0;
    return 0;
  }

  int? get daysLeft => null; // leave as-is for your UI; compute if needed
}


