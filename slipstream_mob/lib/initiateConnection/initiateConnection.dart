import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

class InitiateConnection extends StatefulWidget {
  const InitiateConnection({super.key});

  @override
  State<InitiateConnection> createState() => _InitiateConnectionState();
}

class _InitiateConnectionState extends State<InitiateConnection> {
  final CentralManager _centralManager = CentralManager();

  bool isScanning = false;

  final List<DiscoveredEventArgs> devices = [];

  StreamSubscription<DiscoveredEventArgs>? _discoveredSubscription;
  StreamSubscription<BluetoothLowEnergyStateChangedEventArgs>?
      _stateSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for discovered BLE devices
    _discoveredSubscription =
        _centralManager.discovered.listen((event) {
      debugPrint(
        "Found BLE device: ${event.peripheral}",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        devices.add(event);
      });
    });

    // Listen for Bluetooth state changes
    _stateSubscription =
        _centralManager.stateChanged.listen((event) {
      debugPrint(
        "Bluetooth state changed: ${event.state}",
      );

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> startBluetooth() async {
    try {
      // --------------------------------
      // 1. ASK FOR BLUETOOTH PERMISSION
      // --------------------------------

      final authorized = await _centralManager.authorize();

      debugPrint(
        "Bluetooth permission: $authorized",
      );

      if (!authorized) {
        showMessage(
          "Bluetooth permission was denied.",
        );
        return;
      }

      // --------------------------------
      // 2. CHECK BLUETOOTH STATE
      // --------------------------------

      final state = _centralManager.state;

      debugPrint(
        "Bluetooth state: $state",
      );

      // --------------------------------
      // 3. IF BLUETOOTH IS OFF
      // --------------------------------

      if (state == BluetoothLowEnergyState.poweredOff) {
        showMessage(
          "Bluetooth is OFF. Please turn it ON.",
        );

        // Android does not allow a normal app
        // to silently turn Bluetooth on.
        //
        // We will handle the Android Bluetooth
        // enable dialog separately if needed.

        return;
      }

      // --------------------------------
      // 4. IF BLUETOOTH IS ON
      // --------------------------------

      if (state == BluetoothLowEnergyState.poweredOn) {
        await discoverDevices();
        return;
      }

      if (state == BluetoothLowEnergyState.unsupported) {
        showMessage(
          "Bluetooth Low Energy is not supported.",
        );
        return;
      }

      if (state == BluetoothLowEnergyState.unauthorized) {
        showMessage(
          "Bluetooth permission is not authorized.",
        );
        return;
      }

      showMessage(
        "Bluetooth is not ready.",
      );
    } catch (e) {
      debugPrint(
        "Bluetooth error: $e",
      );

      showMessage(
        "Bluetooth error: $e",
      );
    }
  }

  Future<void> discoverDevices() async {
    if (isScanning) {
      return;
    }

    setState(() {
      isScanning = true;
      devices.clear();
    });

    debugPrint(
      "Starting BLE discovery...",
    );

    try {
      await _centralManager.startDiscovery();

      // Discover for 5 seconds
      await Future.delayed(
        const Duration(seconds: 5),
      );

      await _centralManager.stopDiscovery();

      debugPrint(
        "BLE discovery finished.",
      );

      debugPrint(
        "Devices found: ${devices.length}",
      );
    } catch (e) {
      debugPrint(
        "BLE discovery error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _discoveredSubscription?.cancel();
    _stateSubscription?.cancel();

    if (isScanning) {
      _centralManager.stopDiscovery();
    }

    super.dispose();
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

      body: Column(
        children: [
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: isScanning
                ? null
                : startBluetooth,

            child: Text(
              isScanning
                  ? "Scanning..."
                  : "Start Bluetooth",
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: devices.isEmpty
                ? Center(
                    child: Text(
                      isScanning
                          ? "Searching for BLE devices..."
                          : "No BLE devices found.",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: devices.length,

                    itemBuilder: (context, index) {
                      final device =
                          devices[index].peripheral;

                      return ListTile(
                        leading: const Icon(
                          Icons.bluetooth,
                          color: Colors.white,
                        ),

                        title: Text(
                          device.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
