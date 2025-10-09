// Generated Dart model classes for the provided JSON
// Filename: chat_model.dart

import 'dart:convert';

class ChatResponse {
  final bool success;
  final String message;
  final List<ChatItem> data;

  ChatResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ChatItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() => jsonEncode(toJson());
}

class ChatItem {
  final String id;
  final Auction auction;
  final String user;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ChatItem({
    required this.id,
    required this.auction,
    required this.user,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['_id'] as String? ?? '',
      auction: Auction.fromJson(json['auction'] as Map<String, dynamic>),
      user: json['user'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      v: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'auction': auction.toJson(),
    'user': user,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
  };
}

class Auction {
  final Schedule schedule;
  final String id;
  final String name;
  final String description;
  final List<String> category;
  final int startingBid;
  final List<ImageItem> image;
  final List<String> skills;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Auction({
    required this.schedule,
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.startingBid,
    required this.image,
    required this.skills,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      schedule:
      Schedule.fromJson(json['schedule'] as Map<String, dynamic>? ?? {}),
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      startingBid: (json['starting_bid'] is int)
          ? (json['starting_bid'] as int)
          : int.tryParse((json['starting_bid'] ?? '').toString()) ?? 0,
      image: (json['image'] as List<dynamic>?)
          ?.map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      v: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'schedule': schedule.toJson(),
    '_id': id,
    'name': name,
    'description': description,
    'category': category,
    'starting_bid': startingBid,
    'image': image.map((e) => e.toJson()).toList(),
    'skills': skills,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
  };
}

class Schedule {
  final String date; // kept as String because format is dd-MM-yyyy in sample
  final String time; // kept as String

  Schedule({required this.date, required this.time});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'time': time,
  };
}

class ImageItem {
  final String url;
  final String filename;
  final String publicId;
  final String id;

  ImageItem({
    required this.url,
    required this.filename,
    required this.publicId,
    required this.id,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      url: json['url'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      publicId: json['public_id'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'filename': filename,
    'public_id': publicId,
    '_id': id,
  };
}

// Example quick parser helper
ChatResponse parseChatResponse(String jsonStr) =>
    ChatResponse.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
