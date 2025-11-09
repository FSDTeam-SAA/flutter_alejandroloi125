import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../model/model.dart';
import '../service/alart_service.dart';


class NotificationController extends GetxController {
  final Dio dio = Dio();
  final notifications = <AppNotification>[].obs;
  final SocketService socketService = SocketService();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    initSocket();
  }

  /// ✅ Fetch old notifications using Dio
  Future<void> fetchNotifications() async {
    try {
      final response = await dio.get('https://your-server.com/api/notifications');
      if (response.statusCode == 200) {
        final List data = response.data;
        notifications.value =
            data.map((e) => AppNotification.fromJson(e)).toList();
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    }
  }

  /// ✅ Socket setup
  void initSocket() {
    socketService.connect((data) {
      final newNotif = AppNotification.fromJson(data);
      notifications.insert(0, newNotif);
      Get.snackbar(
        newNotif.title,
        newNotif.message,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  @override
  void onClose() {
    socketService.dispose();
    super.onClose();
  }
}
