// lib/feature/auction/models/auction_create.dart
class AuctionCreateRequest {
  final String name;
  final String description;
  final List<String> category;
  final int startingBid;   // minutes
  final int duration;      // minutes
  final String location;
  final String date;       // dd-MM-yyyy
  final String time;       // h:mm (AM/PM optional)
  final String imagePath;  // required (local path)

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
}
