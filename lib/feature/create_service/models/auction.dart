class Auction {
  final String? id;
  final String? name;
  final String? description;
  final String? category;
  final int? startingBid;
  final String? location;
  final int? duration; // minutes
  final String? scheduleDate;
  final String? scheduleTime;

  Auction({
    this.id,
    this.name,
    this.description,
    this.category,
    this.startingBid,
    this.location,
    this.duration,
    this.scheduleDate,
    this.scheduleTime,
  });

  factory Auction.fromMap(Map<String, dynamic> m) => Auction(
    id: (m['_id'] ?? m['id'])?.toString(),
    name: m['name']?.toString(),
    description: m['description']?.toString(),
    category: m['category']?.toString(),
    startingBid: m['starting_bid'] is int ? m['starting_bid'] as int : int.tryParse('${m['starting_bid']}'),
    location: m['location']?.toString(),
    duration: m['duration'] is int ? m['duration'] as int : int.tryParse('${m['duration']}'),
    scheduleDate: (m['schedule'] is Map) ? (m['schedule']['date']?.toString()) : null,
    scheduleTime: (m['schedule'] is Map) ? (m['schedule']['time']?.toString()) : null,
  );
}
