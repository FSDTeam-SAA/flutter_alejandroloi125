

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../controller/alart_controller.dart';

// class AlartScreenView extends StatelessWidget {
//   const AlartScreenView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(NotificationController());

//     return Scaffold(
//       appBar: AppBar(title: const Text('🔔 Notifications')),
//       body: Obx(() {
//         if (controller.notifications.isEmpty) {
//           return const Center(child: Text('No notifications yet'));
//         }

//         return ListView.builder(
//           itemCount: controller.notifications.length,
//           itemBuilder: (context, index) {
//             final notif = controller.notifications[index];
//             return ListTile(
//               leading: const Icon(Icons.notifications),
//               title: Text(notif.title),
//               subtitle: Text(notif.message),
//             );
//           },
//         );
//       }),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../service/notificatin_service.dart';
class AlartScreenView extends StatefulWidget {
  const AlartScreenView({super.key});

  @override
  State<AlartScreenView> createState() => _AlartScreenViewState();
}

class _AlartScreenViewState extends State<AlartScreenView> {
  final NotificationService _notificationService = NotificationService();

  



  @override
  void initState() {
    super.initState();

    print("Fetching notification in initState");
    _notificationService.fetchNotification();
    
  }

  @override
  Widget build(BuildContext context) {


    // if (userId != null) {
    //   _notificationService.fetchNotification(userId);
    // }
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Text('Fetching notification data...'),
      ),
    );
  }
}
