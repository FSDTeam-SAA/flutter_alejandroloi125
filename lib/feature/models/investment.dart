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
  final String? fundingDuration; // e.g. "30 day"
  final String location;
  final String investmentTerms;
  final List<InvestmentImage> images;

  final String? ownerName;          // NEW
  final String? ownerAvatarUrl;     // NEW

  final String? ownerUsername;     // NEW
  final int? likeCount;            // NEW
  final int? viewCount;            // NEW

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
    this.ownerName,                 // NEW
    this.ownerAvatarUrl,            // NEW
    this.ownerUsername,            // NEW
    this.likeCount,                // NEW
    this.viewCount,                // NEW

  });

  factory Investment.fromJson(Map<String, dynamic> j) {

    // -------- parse createdBy safely --------
    String? ownerName;
    String? ownerAvatarUrl;
    String? ownerUsername;
    final createdBy = j['createdBy'];
    if (createdBy is Map) {
      ownerName = (createdBy['name'] ?? '').toString().trim().isEmpty
          ? null
          : (createdBy['name'] ?? '').toString();

      ownerUsername = (createdBy['username'] ?? '').toString().trim().isEmpty
          ? null
          : createdBy['username'].toString();

      final av = createdBy['avatar'];
      if (av is Map) {
        final url = (av['url'] ?? av['imageUrl'] ?? av['link'] ?? '').toString();
        ownerAvatarUrl = url.isEmpty ? null : url;
      } else if (av is String) {
        ownerAvatarUrl = av.isEmpty ? null : av; // in case backend ever returns a plain string
      }
    }




    List<String> cat(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) {
        return v
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    List<InvestmentImage> imgs(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((m) => InvestmentImage.fromJson(Map<String, dynamic>.from(m)))
            .toList();
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
      // accept multiple keys for images
      images: imgs(j['imageLink'] ?? j['image'] ?? j['images']),
      ownerName: ownerName,                 // NEW
      ownerAvatarUrl: ownerAvatarUrl,       // NEW
    );
  }

  String? get primaryImageUrl => images.isNotEmpty ? images.first.url : null;

  int get progressPct {
    // default 0; replace with real calc when backend exposes "raised"
    final goal = fundingGoal ?? 0;
    if (goal <= 0) return 0;
    return 0;
  }

  // CHANGED: previously `=> null`
  // NEW: compute days left from `fundingDuration` (handles "30 day", "30 days", "30", 30.0, or ISO date).
  int? get daysLeft => _parseDaysLeft(fundingDuration); // NEW

  // NEW: robust parser
  static int? _parseDaysLeft(dynamic v) { // NEW
    if (v == null) return null;

    // numeric: 30 / 30.0
    if (v is num) {
      final d = v.toInt();
      return d >= 0 ? d : 0;
    }

    final s = v.toString().trim().toLowerCase();
    if (s.isEmpty) return null;

    // ISO date ("2026-01-31") -> days from now (never negative)
    final asDate = DateTime.tryParse(s);
    if (asDate != null) {
      final delta = asDate.difference(DateTime.now()).inDays;
      return delta >= 0 ? delta : 0;
    }

    // extract first integer: "30 day", "30 days", etc.
    final m = RegExp(r'(\d{1,4})').firstMatch(s);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n != null) return n >= 0 ? n : 0;
    }

    return null;
  } // NEW
}


