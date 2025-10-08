// lib/feature/auction/models/auction_model.dart

class AuctionModel {
  final bool success;
  final String message;
  final AuctionData data;

  AuctionModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) => AuctionModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: AuctionData.fromJson(json['data'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };
}

class AuctionData {
  final AuctionMeta meta;
  final List<AuctionItem> auctions;

  AuctionData({
    required this.meta,
    required this.auctions,
  });

  factory AuctionData.fromJson(Map<String, dynamic> json) => AuctionData(
    meta: AuctionMeta.fromJson(json['meta'] ?? {}),
    auctions: (json['auctions'] as List? ?? []).map((e) => AuctionItem.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'auctions': auctions.map((e) => e.toJson()).toList(),
  };
}

class AuctionMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  AuctionMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory AuctionMeta.fromJson(Map<String, dynamic> json) => AuctionMeta(
    total: json['total'] ?? 0,
    page: json['page'] ?? 0,
    limit: json['limit'] ?? 0,
    pages: json['pages'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'pages': pages,
  };
}

class AuctionItem {
  final String id;
  final String name;
  final String description;
  final List<String> category;
  final int startingBid;
  final List<AuctionImage> image;
  final List<String> skills;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String status;
  final AuctionSchedule schedule;
  final int? duration;

  AuctionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.startingBid,
    required this.image,
    required this.skills,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.schedule,
    this.duration,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) => AuctionItem(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    category: (json['category'] as List? ?? []).map((e) => e.toString()).toList(),
    startingBid: json['starting_bid'] ?? 0,
    image: (json['image'] as List? ?? []).map((e) => AuctionImage.fromJson(e)).toList(),
    skills: (json['skills'] as List? ?? []).map((e) => e.toString()).toList(),
    createdBy: json['createdBy'],
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    status: json['status'] ?? '',
    duration: json['duration'],
    schedule: AuctionSchedule.fromJson(json['schedule'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'category': category,
    'starting_bid': startingBid,
    'image': image.map((e) => e.toJson()).toList(),
    'skills': skills,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'status': status,
    'duration': duration,
    'schedule': schedule.toJson(),
  };
}

class AuctionImage {
  final String url;
  final String filename;
  final String publicId;
  final String id;

  AuctionImage({
    required this.url,
    required this.filename,
    required this.publicId,
    required this.id,
  });

  factory AuctionImage.fromJson(Map<String, dynamic> json) => AuctionImage(
    url: json['url'] ?? '',
    filename: json['filename'] ?? '',
    publicId: json['public_id'] ?? '',
    id: json['_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'url': url,
    'filename': filename,
    'public_id': publicId,
    '_id': id,
  };
}

class AuctionSchedule {
  final String date;
  final String time;

  AuctionSchedule({
    required this.date,
    required this.time,
  });

  factory AuctionSchedule.fromJson(Map<String, dynamic> json) => AuctionSchedule(
    date: json['date'] ?? '',
    time: json['time'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'time': time,
  };
}
