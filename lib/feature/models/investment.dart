// lib/feature/investment/model/investment.dart
class InvestmentImage {
  final String url;
  final String filename;
  final String publicId;

  const InvestmentImage({
    required this.url,
    required this.filename,
    required this.publicId,
  });

  factory InvestmentImage.fromJson(Map<String, dynamic> j) => InvestmentImage(
    url: (j['url'] ?? j['imageUrl'] ?? '').toString(),
    filename: (j['filename'] ?? j['name'] ?? '').toString(),
    publicId: (j['public_id'] ?? j['publicId'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'url': url,
    'filename': filename,
    'public_id': publicId,
  };
}

class InvestEntry {
  final String? userId; // ObjectId as string
  final num amount;
  final DateTime date;
  final String? paymentId;
  final String paymentStatus; // pending, paid, failed...

  const InvestEntry({
    required this.userId,
    required this.amount,
    required this.date,
    this.paymentId,
    this.paymentStatus = 'pending',
  });

  factory InvestEntry.fromJson(Map<String, dynamic> j) => InvestEntry(
    userId: j['user']?.toString(),
    amount: (j['amount'] as num?) ?? 0,
    date: j['date'] != null ? DateTime.tryParse(j['date'].toString()) ?? DateTime.now() : DateTime.now(),
    paymentId: j['paymentId']?.toString(),
    paymentStatus: (j['payment_status'] ?? 'pending').toString(),
  );

  Map<String, dynamic> toJson() => {
    'user': userId,
    'amount': amount,
    'date': date.toIso8601String(),
    'paymentId': paymentId,
    'payment_status': paymentStatus,
  };
}

class Investment {
  final String id;
  final String name;
  final String description;
  final List<String> category;        // schema: [String]
  final int? fundingGoal;             // schema: Number
  final String? fundingDuration;      // schema: String (e.g., "6 month")
  final String location;
  final String investmentTerms;
  final List<InvestmentImage> images; // schema: image: [{ url, filename, public_id }]
  final List<InvestEntry> invest;     // schema: invest: [{...}]
  final String? createdBy;            // ObjectId as string
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    required this.invest,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Defensive parsing: handles several backend shapes.
  factory Investment.fromJson(Map<String, dynamic> j) {
    String _pickId(Map m) => (m['_id'] ?? m['id'] ?? '').toString();

    List<String> _parseCategory(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) {
        // accept "build" or "a,b,c"
        return v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return const <String>[];
    }

    List<InvestmentImage> _parseImages(dynamic v) {
      if (v is List) {
        return v.map<InvestmentImage?>((e) {
          if (e is Map) return InvestmentImage.fromJson(Map<String, dynamic>.from(e));
          if (e is String) return InvestmentImage(url: e, filename: '', publicId: '');
          return null;
        }).whereType<InvestmentImage>().toList();
      }
      return const <InvestmentImage>[];
    }

    List<InvestEntry> _parseInvest(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((m) => InvestEntry.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return const <InvestEntry>[];
    }

    int? _intOrNull(dynamic v) {
      if (v is num) return v.toInt();
      final s = v?.toString();
      return s == null ? null : int.tryParse(s);
    }

    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return Investment(
      id: _pickId(j),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      category: _parseCategory(j['category']),
      fundingGoal: _intOrNull(j['funding_goal'] ?? j['fundingGoal']),
      fundingDuration: (j['funding_duration'] ?? j['fundingDuration'])?.toString(),
      location: (j['location'] ?? '').toString(),
      investmentTerms: (j['investment_terms'] ?? '').toString(),
      images: _parseImages(j['image'] ?? j['images']),
      invest: _parseInvest(j['invest']),
      createdBy: j['createdBy']?.toString(),
      createdAt: _dt(j['createdAt']),
      updatedAt: _dt(j['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'category': category,
    'funding_goal': fundingGoal,
    'funding_duration': fundingDuration,
    'location': location,
    'investment_terms': investmentTerms,
    'image': images.map((e) => e.toJson()).toList(),
    'invest': invest.map((e) => e.toJson()).toList(),
    'createdBy': createdBy,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // ---------- helpers (nice for UI) ----------
  String? get primaryImageUrl => images.isNotEmpty ? images.first.url : null;

  int get totalRaised =>
      invest.fold<int>(0, (sum, e) => sum + (e.amount).toInt());

  int get progressPct {
    final goal = fundingGoal ?? 0;
    if (goal <= 0) return 0;
    final pct = (totalRaised / goal) * 100;
    final clamped = pct.clamp(0, 100);
    return clamped.round();
  }

  /// Uses `funding_duration` ("6 month", "10 days", "3 weeks") + `createdAt`.
  int? get daysLeft {
    if (fundingDuration == null || fundingDuration!.isEmpty || createdAt == null) return null;
    final s = fundingDuration!.toLowerCase();
    final n = int.tryParse(RegExp(r'\d+').firstMatch(s)?.group(0) ?? '');
    if (n == null) return null;

    int totalDays;
    if (s.contains('month')) {
      totalDays = n * 30;
    } else if (s.contains('week')) {
      totalDays = n * 7;
    } else {
      totalDays = n; // treat as days
    }

    final end = createdAt!.add(Duration(days: totalDays));
    final left = end.difference(DateTime.now()).inDays;
    return left < 0 ? 0 : left;
  }

  Investment copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? category,
    int? fundingGoal,
    String? fundingDuration,
    String? location,
    String? investmentTerms,
    List<InvestmentImage>? images,
    List<InvestEntry>? invest,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      fundingDuration: fundingDuration ?? this.fundingDuration,
      location: location ?? this.location,
      investmentTerms: investmentTerms ?? this.investmentTerms,
      images: images ?? this.images,
      invest: invest ?? this.invest,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
