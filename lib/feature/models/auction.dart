import 'dart:convert';

/// ====== CREATE (unchanged) ======
class AuctionCreateRequest {
  final String name;
  final String description;
  final List<String> category;
  final int startingBid;   // -> starting_bid
  final int duration;      // minutes
  final String location;
  final String date;       // "dd-MM-yyyy"
  final String time;       // "h:mm" (AM/PM optional)
  final String imagePath;  // required

  AuctionCreateRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.startingBid,
    required this.duration,
    required this.location,
    required this.date,
    required this.time,
    required this.imagePath,
  });

  Map<String, String> toMultipartFields() => {
    'name': name,
    'description': description,
    'starting_bid': startingBid.toString(),
    'duration': duration.toString(),
    'location': location,
    'schedule': jsonEncode({'date': date, 'time': time}),
  };
}

class AuctionResponse {
  final String id;
  final String message;
  AuctionResponse({required this.id, required this.message});

  factory AuctionResponse.fromJson(Map<String, dynamic> j) {
    final root = j;
    final data = (root['data'] is Map)
        ? (root['data'] as Map).cast<String, dynamic>()
        : root;
    return AuctionResponse(
      id: (data['_id'] ?? data['id'] ?? '').toString(),
      message: (root['message'] ?? 'Auction created successfully').toString(),
    );
  }
}

/// ====== READ (list/detail) ======
class AuctionImageDto {
  final String url;
  final String filename;
  final String publicId;
  AuctionImageDto({required this.url, required this.filename, required this.publicId});

  factory AuctionImageDto.fromJson(Map<String, dynamic> j) => AuctionImageDto(
    url: (j['url'] ?? '').toString(),
    filename: (j['filename'] ?? '').toString(),
    publicId: (j['public_id'] ?? '').toString(),
  );
}

class AuctionScheduleDto {
  final String date; // dd-MM-yyyy
  final String time; // h:mm / h:mm AM
  AuctionScheduleDto({required this.date, required this.time});
  factory AuctionScheduleDto.fromJson(Map<String, dynamic> j) => AuctionScheduleDto(
    date: (j['date'] ?? '').toString(),
    time: (j['time'] ?? '').toString(),
  );
}

class AuctionDto {
  final String id;
  final String name;
  final String description;
  final List<String> category;
  final int startingBid;
  final List<AuctionImageDto> image;
  final int? duration;
  final AuctionScheduleDto schedule;
  final List<String> skills;
  final String? createdBy;

  // (CHANGE HERE) add location
  final String location;

  AuctionDto({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.startingBid,
    required this.image,
    required this.duration,
    required this.schedule,
    required this.skills,
    required this.createdBy,
    // (CHANGE HERE) add to constructor
    required this.location,
  });

  factory AuctionDto.fromJson(Map<String, dynamic> j) => AuctionDto(
    id: (j['_id'] ?? j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
    category: (j['category'] is List ? (j['category'] as List) : const [])
        .map((e) => e.toString())
        .toList(),
    startingBid: (j['starting_bid'] ?? 0) is int
        ? j['starting_bid'] as int
        : int.tryParse('${j['starting_bid']}') ?? 0,
    image: (j['image'] is List ? j['image'] as List : const [])
        .map((e) => AuctionImageDto.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    duration: (j['duration'] == null)
        ? null
        : (j['duration'] is int ? j['duration'] as int : int.tryParse('${j['duration']}')),
    schedule: AuctionScheduleDto.fromJson((j['schedule'] as Map).cast<String, dynamic>()),
    skills: (j['skills'] is List ? j['skills'] as List : const [])
        .map((e) => e.toString())
        .toList(),
    createdBy: j['createdBy']?.toString(),
    // (CHANGE HERE) parse location safely
    location: (j['location'] ?? '').toString(),
  );
}


// class AuctionDto {
//   final String id;
//   final String name;
//   final String description;
//   final List<String> category;
//   final int startingBid;
//   final List<AuctionImageDto> image;
//   final int? duration; // minutes
//   final AuctionScheduleDto schedule;
//   final List<String> skills;
//   final String? createdBy;
//
//   AuctionDto({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.category,
//     required this.startingBid,
//     required this.image,
//     required this.duration,
//     required this.schedule,
//     required this.skills,
//     required this.createdBy,
//   });
//
//   factory AuctionDto.fromJson(Map<String, dynamic> j) => AuctionDto(
//     id: (j['_id'] ?? j['id'] ?? '').toString(),
//     name: (j['name'] ?? '').toString(),
//     description: (j['description'] ?? '').toString(),
//     category: (j['category'] is List
//         ? (j['category'] as List)
//         : <dynamic>[])
//         .map((e) => e.toString())
//         .toList(),
//     startingBid: (j['starting_bid'] ?? 0) is int
//         ? j['starting_bid'] as int
//         : int.tryParse('${j['starting_bid']}') ?? 0,
//     image: (j['image'] is List ? j['image'] as List : const [])
//         .map((e) => AuctionImageDto.fromJson(
//         (e as Map).cast<String, dynamic>()))
//         .toList(),
//     duration: (j['duration'] == null)
//         ? null
//         : (j['duration'] is int
//         ? j['duration'] as int
//         : int.tryParse('${j['duration']}')),
//     schedule: AuctionScheduleDto.fromJson(
//         (j['schedule'] as Map).cast<String, dynamic>()),
//     skills: (j['skills'] is List ? j['skills'] as List : const [])
//         .map((e) => e.toString())
//         .toList(),
//     createdBy: j['createdBy']?.toString(),
//   );
// }

class AuctionListResponse {
  final int total;
  final int page;
  final int limit;
  final int pages;
  final List<AuctionDto> auctions;

  AuctionListResponse({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.auctions,
  });

  // factory AuctionListResponse.fromJson(Map<String, dynamic> j) {
  //   final data = (j['data'] as Map).cast<String, dynamic>();
  //   final meta = (data..remove('auctions'));
  //   final list = (data['auctions'] as List? ?? const [])
  //       .map((e) => AuctionDto.fromJson((e as Map).cast<String, dynamic>()))
  //       .toList();
  //   return AuctionListResponse(
  //     total: (meta['total'] ?? list.length) as int,
  //     page: (meta['page'] ?? 1) as int,
  //     limit: (meta['limit'] ?? list.length) as int,
  //     pages: (meta['pages'] ?? 1) as int,
  //     auctions: list,
  //   );
  // }

  // lib/feature/models/auction.dart  (where AuctionListResponse lives)
// REPLACE the factory with this exact version
  factory AuctionListResponse.fromJson(Map<String, dynamic> j) {
    final data = (j['data'] is Map) ? Map<String, dynamic>.from(j['data']) : <String, dynamic>{};
    final meta = (data['meta'] is Map) ? Map<String, dynamic>.from(data['meta']) : <String, dynamic>{};
    final list = (data['auctions'] is List) ? List.from(data['auctions']) : const <dynamic>[];

    final items = list
        .whereType<Map>()
        .map((m) => AuctionDto.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    int _i(dynamic v, int d) => (v is num) ? v.toInt() : int.tryParse('$v') ?? d;

    return AuctionListResponse(
      total: _i(meta['total'], items.length),
      page : _i(meta['page'], 1),
      limit: _i(meta['limit'], items.length),
      pages: _i(meta['pages'], 1),
      auctions: items,
    );
  }


}


