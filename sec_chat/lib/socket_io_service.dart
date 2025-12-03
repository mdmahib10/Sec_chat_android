import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket socket;

void serverConnect() {
  socket = IO.io(
    'http://localhost:5000',
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  socket.connect();
  socket.onConnect((_) {
    print('connected to server');
  });

  socket.onDisconnect((_) => print('Disconnected from server...'));
  socket.onConnectError((_) => print('Connection error ...'));
  socket.onError((data) => print('Error: $data'));
}

void msgSend(String msg) {
  socket.emit('message', msg);
}
