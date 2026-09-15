import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';

class InitiateConnection extends StatefulWidget {
  const InitiateConnection({super.key});

  @override
  State<InitiateConnection> createState() => _InitiateConnectionState();
}

class _InitiateConnectionState extends State<InitiateConnection> {

  static const MethodChannel _channel =
      MethodChannel('slipstream/bluetooth');

  Future<void> turnOnBluetooth() async {

    // Ask Android for Nearby Devices permission
    await _channel.invokeMethod('requestBluetoothPermission');

    // Check Bluetooth
    final bluetooth = FlutterBluetoothSerial.instance;

    bool? isEnabled = await bluetooth.isEnabled;

    // Turn Bluetooth on if it is currently off
    if (isEnabled == false) {
      await bluetooth.requestEnable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Welcome, User",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),

      body: Center(
        child: ElevatedButton(
          onPressed: turnOnBluetooth,
          child: const Text("Turn On Bluetooth"),
        ),
      ),
    );
  }
}

