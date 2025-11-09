import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(Function(Map<String, dynamic>) onNotification) {
    socket = IO.io('https://your-server.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to socket');
    });

    socket.on('notification', (data) {
      print(' Socket Data: $data');
      onNotification(Map<String, dynamic>.from(data));
    });

    socket.onDisconnect((_) => print(' Disconnected from socket'));
  }

  void dispose() {
    socket.dispose();
  }
}
