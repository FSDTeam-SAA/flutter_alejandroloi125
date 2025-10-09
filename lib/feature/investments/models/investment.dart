// // lib/feature/investment/models/investment.dart
// import 'dart:convert';
//
// class InvImage {
//   final String url;
//   final String filename;
//   final String publicId;
//   const InvImage({required this.url, required this.filename, required this.publicId});
//
//   factory InvImage.fromJson(Map<String, dynamic> j) => InvImage(
//     url: (j['url'] ?? '').toString(),
//     filename: (j['filename'] ?? '').toString(),
//     publicId: (j['public_id'] ?? j['publicId'] ?? '').toString(),
//   );
// }
//
// class Investment {
//   final String id;
//   final String name;
//   final String description;
//   final String? category;      // sometimes string, sometimes list -> we join in fromJson
//   final int fundingGoal;       // may be 0 if absent
//   final int amountRaised;      // optional
//   final int? fundingDuration;  // days or minutes depending on backend; we keep as int?
//   final String? location;
//   final List<InvImage> images;
//   final String? createdAt;
//
//   const Investment({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.category,
//     required this.fundingGoal,
//     required this.amountRaised,
//     required this.fundingDuration,
//     required this.location,
//     required this.images,
//     required this.createdAt,
//   });
//
//   factory Investment.fromJson(Map<String, dynamic> j) {
//     String? _category() {
//       final c = j['category'];
//       if (c is String) return c;
//       if (c is List) return c.map((e) => e.toString()).join(', ');
//       return null;
//     }
//
//     int _int(dynamic v, [int d = 0]) =>
//         (v is num) ? v.toInt() : int.tryParse('$v') ?? d;
//
//     final imgs = (j['image'] ?? j['images']);
//     final imgList = (imgs is List ? imgs : const [])
//         .whereType<Map>()
//         .map((m) => InvImage.fromJson(Map<String, dynamic>.from(m)))
//         .toList();
//
//     return Investment(
//       id: (j['_id'] ?? j['id'] ?? '').toString(),
//       name: (j['name'] ?? j['title'] ?? '').toString(),
//       description: (j['description'] ?? '').toString(),
//       category: _category(),
//       fundingGoal: _int(j['fundingGoal'] ?? j['funding_goal']),
//       amountRaised: _int(j['amountRaised'] ?? j['raised']),
//       fundingDuration: (j['fundingDuration'] ?? j['funding_duration']) is num
//           ? (j['fundingDuration'] ?? j['funding_duration'] as num).toInt()
//           : int.tryParse('${j['fundingDuration'] ?? j['funding_duration']}'),
//       location: j['location']?.toString(),
//       images: imgList,
//       createdAt: j['createdAt']?.toString(),
//     );
//   }
//
//   String? get primaryImage => images.isNotEmpty ? images.first.url : null;
// }
//
// class InvestmentPage {
//   final int total, page, limit, pages;
//   final List<Investment> items;
//   const InvestmentPage({
//     required this.total,
//     required this.page,
//     required this.limit,
//     required this.pages,
//     required this.items,
//   });
//
//   factory InvestmentPage.fromJson(Map<String, dynamic> root) {
//     final data = (root['data'] is Map) ? Map<String, dynamic>.from(root['data']) : <String, dynamic>{};
//     // In your Postman, investments list is under "investments"
//     final meta = (data['meta'] is Map) ? Map<String, dynamic>.from(data['meta']) : <String, dynamic>{};
//     final list = (data['investments'] is List) ? List.from(data['investments']) : const <dynamic>[];
//
//     int _int(dynamic v, [int d = 0]) =>
//         (v is num) ? v.toInt() : int.tryParse('$v') ?? d;
//
//     final items = list
//         .whereType<Map>()
//         .map((m) => Investment.fromJson(Map<String, dynamic>.from(m)))
//         .toList();
//
//     return InvestmentPage(
//       total: _int(meta['total'], items.length),
//       page:  _int(meta['page'], 1),
//       limit: _int(meta['limit'], items.length),
//       pages: _int(meta['pages'], 1),
//       items: items,
//     );
//   }
// }
//
// /// Create/Update request (use multipart if you upload images)
// class InvestmentUpsertRequest {
//   final String name;
//   final String description;
//   final String category;
//   final int fundingGoal;
//   final int fundingDuration; // days
//   final String location;
//   final List<String> imagePaths; // local file paths (optional)
//
//   InvestmentUpsertRequest({
//     required this.name,
//     required this.description,
//     required this.category,
//     required this.fundingGoal,
//     required this.fundingDuration,
//     required this.location,
//     this.imagePaths = const [],
//   });
//
//   Map<String, String> toFields() => {
//     'name': name,
//     'description': description,
//     'category': category,
//     'funding_goal': fundingGoal.toString(),
//     'funding_duration': fundingDuration.toString(),
//     'location': location,
//   };
// }
