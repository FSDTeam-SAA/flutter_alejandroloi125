class AppNotification {
  final String title;
  final String message;

  AppNotification({
    required this.title,
    required this.message,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
