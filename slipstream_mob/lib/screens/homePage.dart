import 'package:flutter/material.dart';
import 'package:slipstream_mob/normalComponents/button.dart';
import 'package:slipstream_mob/testPages/successPage.dart';
import 'package:slipstream_mob/services/network_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NetworkService networkService = NetworkService();

  // Your laptop's IPv4 address
  final String laptopIp = "192.168.1.38";

  // Port used by the Python server
  final int port = 5000;

  bool isConnected = false;
  bool isConnecting = false;

  Future<void> toggleConnection() async {
    // If already connected → disconnect
    if (isConnected) {
      await networkService.disconnect();

      if (mounted) {
        setState(() {
          isConnected = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Disconnected from laptop"),
          ),
        );
      }

      return;
    }

    // Prevent multiple connection attempts
    if (isConnecting) {
      return;
    }

    setState(() {
      isConnecting = true;
    });

    final connected = await networkService.connect(
      laptopIp,
      port,
    );

    if (!mounted) return;

    setState(() {
      isConnecting = false;
      isConnected = connected;
    });

    if (connected) {
      // Test message
      networkService.send("Hello from SlipStream");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connected to laptop!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not connect to laptop"),
        ),
      );
    }
  }

  void sendTestMessage() {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connect to the laptop first"),
        ),
      );

      return;
    }

    networkService.send("Test message from Flutter");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Message sent!"),
      ),
    );
  }

  @override
  void dispose() {
    networkService.disconnect();
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Connection status
            Text(
              isConnecting
                  ? "Connecting..."
                  : isConnected
                      ? "Connected to Laptop"
                      : "Not Connected",
              style: TextStyle(
                color: isConnected
                    ? Colors.green
                    : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Connect / Disconnect button
            ElevatedButton(
              onPressed: isConnecting
                  ? null
                  : toggleConnection,
              child: Text(
                isConnecting
                    ? "Connecting..."
                    : isConnected
                        ? "Disconnect"
                        : "Connect to Laptop",
              ),
            ),

            const SizedBox(height: 20),

            // Test message button
            ElevatedButton(
              onPressed: sendTestMessage,
              child: const Text(
                "Send Test Message",
              ),
            ),

            const SizedBox(height: 40),

            // Your existing button
            MyButton(
              page: SuccessPage(),
              text: "Check button",
            ),
          ],
        ),
      ),
    );
  }
}