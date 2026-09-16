import 'dart:convert';
import 'dart:io';

class NetworkService {
  RawDatagramSocket? _socket;

  InternetAddress? _laptopAddress;
  int? _laptopPort;

  // Fixed local UDP port for the phone.
  static const int localPort = 5001;

  bool get isConnected =>
      _socket != null &&
      _laptopAddress != null &&
      _laptopPort != null;

  // ============================================================
  // CONNECT
  // ============================================================

  Future<bool> connect(String ip, int port) async {
    // Close previous UDP socket before creating a new one.
    await disconnect();

    try {
      final address = InternetAddress(ip);

      // Create ONE UDP socket on the fixed phone port.
      final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        localPort,
      );

      _socket = socket;
      _laptopAddress = address;
      _laptopPort = port;

      print('========================================');
      print('          SLIPSTREAM UDP CONNECTED');
      print('========================================');
      print('Laptop IP   : $ip');
      print('Laptop Port : $port');
      print('Phone Port  : ${socket.port}');
      print('========================================');

      // --------------------------------------------------------
      // CONNECTION TEST
      // --------------------------------------------------------

      final testMessage = jsonEncode({
        "type": "connection_test",
        "message": "Hello from SlipStream",
      });

      final result = socket.send(
        utf8.encode(testMessage),
        address,
        port,
      );

      print(
        'UDP TEST PACKET SENT: $result bytes',
      );

      return true;
    } catch (e) {
      print('========================================');
      print('          UDP CONNECTION FAILED');
      print('========================================');
      print(e);
      print('========================================');

      _socket = null;
      _laptopAddress = null;
      _laptopPort = null;

      return false;
    }
  }

  // ============================================================
  // SEND
  // ============================================================

  void send(String message) {
    final socket = _socket;
    final address = _laptopAddress;
    final port = _laptopPort;

    if (socket == null ||
        address == null ||
        port == null) {
      print('UDP NOT CONNECTED');
      return;
    }

    try {
      final data = utf8.encode(message);

      final result = socket.send(
        data,
        address,
        port,
      );

      print(
        'UDP SENT [$result bytes]: $message',
      );
    } catch (e) {
      print(
        'UDP SEND ERROR: $e',
      );
    }
  }

  // ============================================================
  // DISCONNECT
  // ============================================================

  Future<void> disconnect() async {
    final socket = _socket;

    _socket = null;
    _laptopAddress = null;
    _laptopPort = null;

    if (socket == null) {
      return;
    }

    try {
      socket.close();

      print(
        'UDP DISCONNECTED',
      );
    } catch (e) {
      print(
        'UDP DISCONNECT ERROR: $e',
      );
    }
  }
}