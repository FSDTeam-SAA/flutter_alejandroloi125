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
  final String? status; // <--- NEW

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
    this.status, // <--- NEW
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
    status: j['status']?.toString(), // <--- NEW
  );
}



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

    int i(dynamic v, int d) => (v is num) ? v.toInt() : int.tryParse('$v') ?? d;

    return AuctionListResponse(
      total: i(meta['total'], items.length),
      page : i(meta['page'], 1),
      limit: i(meta['limit'], items.length),
      pages: i(meta['pages'], 1),
      auctions: items,
    );
  }




}


class BidMessageDto {
  final String id;
  final String? auction; // id or null depending on backend shape
  final String? user;    // id of user
  final int amount;
  final String message;
  final DateTime createdAt;

  BidMessageDto({
    required this.id,
    required this.auction,
    required this.user,
    required this.amount,
    required this.message,
    required this.createdAt,
  });

  factory BidMessageDto.fromJson(Map<String, dynamic> j) {
    int _i(dynamic v, [int d = 0]) => (v is num) ? v.toInt() : int.tryParse('$v') ?? d;
    DateTime _dt(dynamic v) => DateTime.tryParse('$v') ?? DateTime.fromMillisecondsSinceEpoch(0);

    return BidMessageDto(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      auction: j['auction']?.toString(),
      user: j['user']?.toString(),
      amount: _i(j['amount']),
      message: (j['message'] ?? '').toString(),
      createdAt: _dt(j['createdAt']),
    );
  }
}

class BidListResponse {
  final List<BidMessageDto> items;
  BidListResponse(this.items);

  factory BidListResponse.fromJson(Map<String, dynamic> j) {
    final data = (j['data'] is List) ? (j['data'] as List) : const <dynamic>[];
    final items = data
        .whereType<Map>()
        .map((m) => BidMessageDto.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return BidListResponse(items);
  }
}



