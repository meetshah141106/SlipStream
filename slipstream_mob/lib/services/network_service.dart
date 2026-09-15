import 'dart:io';

class NetworkService {
  Socket? _socket;

  bool get isConnected => _socket != null;

  Future<bool> connect(String ip, int port) async {
    // Close any previous connection first
    await disconnect();

    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      _socket = socket;

      print('Connected to laptop: $ip:$port');

      // Detect when laptop/server closes the connection
      socket.done.then((_) {
        print('Connection closed');

        if (_socket == socket) {
          _socket = null;
        }
      });

      return true;
    } catch (e) {
      print('Connection failed: $e');
      _socket = null;
      return false;
    }
  }

  void send(String message) {
    final socket = _socket;

    if (socket == null) {
      print('Not connected');
      return;
    }

    socket.write('$message\n');

    print('Sent: $message');
  }

  Future<void> disconnect() async {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    _socket = null;

    try {
      await socket.close();
    } catch (e) {
      socket.destroy();
    }

    print('Disconnected from laptop');
  }
}