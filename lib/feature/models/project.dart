// lib/feature/project/model/project.dart
class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final int minBudget;
  final int maxBudget;
  final int deadlineDays; // numeric days
  final String location;
  final List<String> skills;
  final String? status;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.minBudget,
    required this.maxBudget,
    required this.deadlineDays,
    required this.location,
    required this.skills,
    this.status,
  });

  factory Project.fromJson(Map<String, dynamic> j) {
    // category can come as string or [string]
    String category;
    final c = j['category'];
    if (c is List) {
      category = c.map((e) => e.toString()).join(', ');
    } else {
      category = (c ?? '').toString();
    }

    // deadline can be number-of-days or a string like "10 day"
    int days = 0;
    if (j['deadline_days'] != null) {
      days = (j['deadline_days'] as num).toInt();
    } else if (j['deadline'] is num) {
      days = (j['deadline'] as num).toInt();
    } else if (j['deadline'] is String) {
      final s = (j['deadline'] as String);
      final m = RegExp(r'\d+').firstMatch(s);
      days = m == null ? 0 : int.parse(m.group(0)!);
    }

    // skills can be list or comma string
    List<String> skills = [];
    final sk = j['skills'];
    if (sk is List) {
      skills = sk.map((e) => e.toString()).toList();
    } else if (sk is String) {
      skills = sk.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return Project(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      title: (j['title'] ?? j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      category: category,
      minBudget: (j['min_budget'] ?? j['budget_min'] ?? 0 as num).toInt(),
      maxBudget: (j['max_budget'] ?? j['budget_max'] ?? 0 as num).toInt(),
      deadlineDays: days,
      location: (j['location'] ?? '').toString(),
      skills: skills,
      status: j['status']?.toString(),
    );
  }
}
