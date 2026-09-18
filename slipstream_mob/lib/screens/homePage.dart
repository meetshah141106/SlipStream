import 'package:flutter/material.dart';
import 'package:slipstream_mob/services/network_service.dart';
import 'package:slipstream_mob/screens/driveController.dart';

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

  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  static const Color background = Color(0xFF080D1A);
  static const Color card = Color(0xFF11182A);
  static const Color cardLight = Color(0xFF18223A);

  static const Color blue = Color(0xFF4F8CFF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF38D9FF);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color green = Color(0xFF35E0A1);

  // ------------------------------------------------------------
  // CONNECTION
  // ------------------------------------------------------------

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
          behavior: SnackBarBehavior.floating,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connected to PC"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not connect to PC"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void openController(String controllerName) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connect to a PC first"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriveController(
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

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: Stack(
        children: [
          // ----------------------------------------------------------
          // BACKGROUND GLOW
          // ----------------------------------------------------------

          Positioned(
            top: -130,
            right: -100,
            child: _glow(
              color: purple,
              size: 300,
            ),
          ),

          Positioned(
            top: 250,
            left: -150,
            child: _glow(
              color: blue,
              size: 280,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                35,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 38),

                  _buildHero(),

                  const SizedBox(height: 28),

                  _buildConnectionCard(),

                  const SizedBox(height: 34),

                  _buildControllerHeader(),

                  const SizedBox(height: 14),

                  _buildRacingController(),

                  const SizedBox(height: 12),

                  _buildGameController(),

                  const SizedBox(height: 30),

                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                blue,
                purple,
              ],
            ),

            borderRadius: BorderRadius.circular(15),

            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),

          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(width: 13),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SlipStream",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              SizedBox(height: 2),

              Text(
                "YOUR PHONE. YOUR CONTROLLER.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),

        _statusPill(),
      ],
    );
  }

  Widget _statusPill() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: isConnected
            ? green.withOpacity(0.10)
            : Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: isConnected
              ? green.withOpacity(0.30)
              : Colors.white.withOpacity(0.08),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,

            decoration: BoxDecoration(
              color: isConnected
                  ? green
                  : Colors.white24,

              shape: BoxShape.circle,

              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: green.withOpacity(0.6),
                        blurRadius: 7,
                      ),
                    ]
                  : null,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            isConnected ? "ONLINE" : "OFFLINE",
            style: TextStyle(
              color: isConnected
                  ? green
                  : Colors.white38,

              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO
  // ------------------------------------------------------------

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ready to",
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),

        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                blue,
                cyan,
                purple,
              ],
            ).createShader(bounds);
          },

          child: const Text(
            "Take Control?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Connect your phone to your PC and\n"
          "turn it into a wireless game controller.",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CONNECTION CARD
  // ------------------------------------------------------------

  Widget _buildConnectionCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardLight,
            card,
          ],
        ),

        borderRadius: BorderRadius.circular(23),

        border: Border.all(
          color: isConnected
              ? green.withOpacity(0.25)
              : blue.withOpacity(0.16),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      blue.withOpacity(0.20),
                      purple.withOpacity(0.20),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: const Icon(
                  Icons.computer_rounded,
                  color: cyan,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PC CONNECTION",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      "UDP • Local Network",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              if (isConnected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: green,
                  size: 23,
                ),
            ],
          ),

          const SizedBox(height: 21),

          const Text(
            "PC IP ADDRESS",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: ipController,
            enabled: !isConnected,
            keyboardType: TextInputType.number,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),

            decoration: InputDecoration(
              hintText: "192.168.1.38",

              hintStyle: const TextStyle(
                color: Colors.white24,
              ),

              prefixIcon: const Icon(
                Icons.lan_rounded,
                color: blue,
                size: 20,
              ),

              filled: true,
              fillColor: const Color(0xFF0A1020),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: blue.withOpacity(0.12),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: blue,
                  width: 1.2,
                ),
              ),

              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(
                  color: green.withOpacity(0.12),
                ),
              ),

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              _smallInfo(
                Icons.dns_rounded,
                "PC $port",
              ),

              const SizedBox(width: 14),

              _smallInfo(
                Icons.phone_android_rounded,
                "Phone 5001",
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton(
              onPressed:
                  isConnecting ? null : toggleConnection,

              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? const Color(0xFF211525)
                    : blue,

                foregroundColor: Colors.white,

                disabledBackgroundColor:
                    blue.withOpacity(0.18),

                elevation: 0,

                shadowColor: blue.withOpacity(0.5),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),

                  side: isConnected
                      ? BorderSide(
                          color: purple.withOpacity(0.3),
                        )
                      : BorderSide.none,
                ),
              ),

              child: isConnecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cyan,
                      ),
                    )
                  : Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          isConnected
                              ? Icons
                                  .power_settings_new_rounded
                              : Icons.wifi_rounded,
                          size: 19,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          isConnected
                              ? "Disconnect"
                              : "Connect to PC",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (isConnected) ...[
            const SizedBox(height: 13),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color: green.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_rounded,
                    color: green,
                    size: 16,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "Connected to ${ipController.text}",
                      style: const TextStyle(
                        color: green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Text(
                    "READY",
                    style: TextStyle(
                      color: green,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white24,
          size: 13,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CONTROLLER HEADER
  // ------------------------------------------------------------

  Widget _buildControllerHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Controller",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Pick your way to play",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: purple.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),

          child: const Text(
            "2 MODES",
            style: TextStyle(
              color: purple,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // RACING CONTROLLER
  // ------------------------------------------------------------

  Widget _buildRacingController() {
    return _controllerCard(
      title: "Racing Controller",
      subtitle: "Gyro steering  •  Throttle  •  Brake",
      icon: Icons.sports_motorsports_rounded,
      accent: orange,
      tag: "RACING",
      onTap: () {
        openController("Racing Controller");
      },
    );
  }

  // ------------------------------------------------------------
  // GAME CONTROLLER
  // ------------------------------------------------------------

  Widget _buildGameController() {
    return _controllerCard(
      title: "Game Controller",
      subtitle: "Dual-stick  •  D-pad  •  ABXY",
      icon: Icons.gamepad_rounded,
      accent: purple,
      tag: "GAMEPAD",
      onTap: () {
        openController("Game Controller");
      },
    );
  }

  Widget _controllerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String tag,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        splashColor: accent.withOpacity(0.08),
        highlightColor: accent.withOpacity(0.04),

        child: Ink(
          width: double.infinity,

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: card,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: accent.withOpacity(0.13),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 61,
                height: 61,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withOpacity(0.25),
                      accent.withOpacity(0.07),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(17),

                  border: Border.all(
                    color: accent.withOpacity(0.15),
                  ),
                ),

                child: Icon(
                  icon,
                  color: accent,
                  size: 31,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),

                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius:
                                BorderRadius.circular(5),
                          ),

                          child: Text(
                            tag,
                            style: TextStyle(
                              color: accent,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 33,
                height: 33,

                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: accent.withOpacity(0.75),
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Colors.white24,
            size: 13,
          ),

          const SizedBox(width: 6),

          const Text(
            "LOCAL NETWORK • PRIVATE CONNECTION",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BACKGROUND GLOW
  // ------------------------------------------------------------

  Widget _glow({
    required Color color,
    required double size,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.12),
              color.withOpacity(0.04),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}