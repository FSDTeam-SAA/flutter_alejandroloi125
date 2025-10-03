class Investment {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final int? fundingGoal;
  final int? progress;
  final int? durationDays;
  final String? status;
  final String? terms;

  // ✅ add this
  final String? imageUrl;

  Investment({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    this.fundingGoal,
    this.progress,
    this.durationDays,
    this.status,
    this.terms,
    this.imageUrl, // ✅
  });

  factory Investment.fromMap(Map<String, dynamic> m) {
    final rawDuration = m['funding_duration'] ?? m['duration'];
    int? parsedDays;
    if (rawDuration is int) {
      parsedDays = rawDuration;
    } else if (rawDuration is String) {
      final n = int.tryParse(RegExp(r'\d+').firstMatch(rawDuration)?.group(0) ?? '');
      if (n != null) {
        if (rawDuration.contains('month')) parsedDays = n * 30;
        if (rawDuration.contains('day')) parsedDays = n;
      }
    }

    // ✅ best-effort pick of first image URL
    String? _pickFirstImageUrl(dynamic v) {
      if (v is List && v.isNotEmpty) {
        final first = v.first;
        if (first is Map && first['url'] is String && (first['url'] as String).isNotEmpty) {
          return first['url'] as String;
        }
        if (first is String && first.isNotEmpty) return first;
      }
      return null;
    }

    return Investment(
      id: (m['_id'] ?? m['id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      category: (m['category'] is List && (m['category'] as List).isNotEmpty)
          ? (m['category'][0] ?? '').toString()
          : (m['category'] ?? '').toString(),
      location: (m['location'] ?? '').toString(),
      fundingGoal: (m['funding_goal'] ?? m['budget_max'] ?? m['goal']) is num
          ? ((m['funding_goal'] ?? m['budget_max'] ?? m['goal']) as num).toInt()
          : int.tryParse((m['funding_goal'] ?? m['budget_max'] ?? m['goal'] ?? '').toString()),
      progress: m['progress'] is num ? (m['progress'] as num).toInt() : null,
      durationDays: parsedDays,
      status: m['status']?.toString(),
      terms: (m['investment_terms'] ?? m['terms'])?.toString(),

      // ✅ new
      imageUrl: _pickFirstImageUrl(m['image']),
    );
  }
}
