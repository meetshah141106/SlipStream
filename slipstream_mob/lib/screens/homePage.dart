import 'package:flutter/material.dart';
import 'package:slipstream_mob/services/network_service.dart';
import 'package:slipstream_mob/screens/controllerPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NetworkService networkService = NetworkService();

  final TextEditingController ipController =
      TextEditingController(text: "192.168.1.38");

  final int port = 5000;

  bool isConnected = false;
  bool isConnecting = false;

  Future<void> toggleConnection() async {
    if (isConnected) {
      await networkService.disconnect();

      if (!mounted) return;

      setState(() {
        isConnected = false;
      });

      return;
    }

    final ip = ipController.text.trim();

    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter the PC IP address"),
        ),
      );
      return;
    }

    if (isConnecting) return;

    setState(() {
      isConnecting = true;
    });

    final connected = await networkService.connect(
      ip,
      port,
    );

    if (!mounted) return;

    setState(() {
      isConnecting = false;
      isConnected = connected;
    });

    if (connected) {
      networkService.send("Hello from SlipStream");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connected to PC"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not connect to PC"),
        ),
      );
    }
  }

  void openController(String controllerName) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connect to a PC first"),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControllerPage(
          controllerName: controllerName,
          networkService: networkService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    ipController.dispose();
    networkService.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          "SlipStream",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Welcome
              const Text(
                "Welcome",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Connect to your PC and choose a controller.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              // Connect section
              const Text(
                "Connect to a PC",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "IP Address",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: ipController,

                      enabled: !isConnected,

                      keyboardType: TextInputType.number,

                      style: const TextStyle(
                        color: Colors.white,
                      ),

                      decoration: InputDecoration(
                        hintText: "192.168.1.38",

                        hintStyle: const TextStyle(
                          color: Colors.white30,
                        ),

                        filled: true,
                        fillColor: Colors.black,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed:
                            isConnecting ? null : toggleConnection,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConnected
                              ? Colors.red.shade700
                              : Colors.white,

                          foregroundColor: isConnected
                              ? Colors.white
                              : Colors.black,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),

                        child: Text(
                          isConnecting
                              ? "Connecting..."
                              : isConnected
                                  ? "Disconnect"
                                  : "Connect",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (isConnected) ...[
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,

                            decoration:
                                const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Connected to ${ipController.text}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Controllers
              const Text(
                "Your Controllers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Racing Controller
              controllerCard(
                icon: Icons.sports_motorsports,
                title: "Racing Controller",
                subtitle: "Steering • Throttle • Brake",
                onTap: () {
                  openController("Racing Controller");
                },
              ),

              const SizedBox(height: 12),

              // Game Controller
              controllerCard(
                icon: Icons.gamepad_outlined,
                title: "Game Controller",
                subtitle: "Standard Gamepad",
                onTap: () {
                  openController("Game Controller");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget controllerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: const Color(0xFF151515),

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: Colors.white12,
            ),
          ),

          child: Row(
            children: [

              Container(
                width: 54,
                height: 54,

                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}