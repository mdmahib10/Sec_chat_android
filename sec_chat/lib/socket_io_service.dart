import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket? socket;
final StreamController<String> connectionStatusController =
    StreamController<String>.broadcast();

void serverConnect(String serverAdd) {
  if (socket?.connected ?? false) {
    socket?.disconnect();
  }
  socket = IO.io(
    'http://$serverAdd:5000',
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  socket?.connect();
  socket?.onConnect((_) {
    print('connected to server');
    connectionStatusController.add('Connected to server');
  });

  socket?.onDisconnect((_) {
    print('Disconnected from server...');
    connectionStatusController.add('Disconnected from server');
  });
  socket?.onConnectError((data) {
    print('Connection error ...');
    connectionStatusController.add('Connection error: $data');
  });
  socket?.onError((data) {
    print('Error: $data');
    connectionStatusController.add('Error: $data');
  });
}

void msgSend(String msg) {
  socket?.emit('message', msg);
}