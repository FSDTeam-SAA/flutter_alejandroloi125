//
// // 🔹 Project model
// class Project {
//   final String? id;
//   final String category;
//   final String title;
//   final String description;
//   final String budget;
//   final int days;
//   final String location;
//   final int proposals;
//   final List<String> memberImages;
//
//   const Project({
//     this.id,
//     required this.category,
//     required this.title,
//     required this.description,
//     required this.budget,
//     required this.days,
//     required this.location,
//     required this.proposals,
//     required this.memberImages,
//   });
//
//   factory Project.fromJson(Map<String, dynamic> json) => Project(
//     id: json['_id']?.toString(),
//     category: json['category'] is List ? (json['category'] as List).join(', ') : json['category']?.toString() ?? '',
//     title: json['name'] ?? '',
//     description: json['description'] ?? '',
//     budget: json['budget_min']?.toString() ?? '0',
//     days: 0,
//     location: json['location'] ?? '',
//     proposals: (json['project_proposal'] as List?)?.length ?? 0,
//     memberImages: List<String>.from(json['image']?.map((e) => e['url']) ?? []),
//   );
// }
