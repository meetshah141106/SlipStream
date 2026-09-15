import 'package:flutter/material.dart';
import 'package:slipstream_mob/services/network_service.dart';

class ControllerPage extends StatefulWidget {
  final String controllerName;
  final NetworkService networkService;

  const ControllerPage({
    super.key,
    required this.controllerName,
    required this.networkService,
  });

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  double steering = 0.0;
  double throttle = 0.0;
  double brake = 0.0;

  int gear = 0;

  bool handbrake = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          widget.controllerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white70,
            ),
            onPressed: resetController,
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [

            // Connection status
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Row(
                children: [

                  Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 9,
                  ),

                  SizedBox(width: 8),

                  Text(
                    "Connected to PC",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),

                  Spacer(),

                  Text(
                    "ONLINE",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main controller
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    // Steering section
                    steeringSection(),

                    const SizedBox(height: 20),

                    // Pedals
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: pedalControl(
                            title: "BRAKE",
                            value: brake,
                            onChanged: (value) {
                              setState(() {
                                brake = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: pedalControl(
                            title: "THROTTLE",
                            value: throttle,
                            onChanged: (value) {
                              setState(() {
                                throttle = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Gear + handbrake
                    Row(
                      children: [

                        Expanded(
                          child: gearSection(),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: handbrakeButton(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Gamepad buttons
                    buttonsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget steeringSection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        children: [

          Row(
            children: [

              const Text(
                "STEERING",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(),

              Text(
                "${(steering * 100).round()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                steering += details.delta.dx / 150;

                steering = steering.clamp(
                  -1.0,
                  1.0,
                );
              });
            },

            onHorizontalDragEnd: (_) {
              setState(() {
                steering = 0.0;
              });
            },

            child: Container(
              height: 190,
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Center(
                child: Transform.rotate(
                  angle: steering * 0.8,

                  child: Container(
                    width: 150,
                    height: 150,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      border: Border.all(
                        color: Colors.white24,
                        width: 12,
                      ),
                    ),

                    child: Center(
                      child: Container(
                        width: 55,
                        height: 55,

                        decoration: const BoxDecoration(
                          color: Color(0xFF181818),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.sports_motorsports,
                          color: Colors.white54,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Drag left or right to steer",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget pedalControl({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      height: 190,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: RotatedBox(
              quarterTurns: 3,

              child: Slider(
                value: value,

                min: 0.0,
                max: 1.0,

                onChanged: onChanged,

                activeColor: Colors.white,
                inactiveColor: Colors.white12,
              ),
            ),
          ),

          Text(
            "${(value * 100).round()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget gearSection() {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        children: [

          const Text(
            "GEAR",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [

              gearButton(-1, "−"),

              Container(
                width: 40,
                height: 40,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Text(
                  gear == 0 ? "N" : gear.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              gearButton(1, "+"),
            ],
          ),
        ],
      ),
    );
  }

  Widget gearButton(int change, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          gear += change;
          gear = gear.clamp(-1, 6);
        });
      },

      child: Container(
        width: 40,
        height: 40,

        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget handbrakeButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          handbrake = !handbrake;
        });
      },

      child: Container(
        height: 92,

        decoration: BoxDecoration(
          color: handbrake
              ? Colors.red.shade900
              : const Color(0xFF111111),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: handbrake
                ? Colors.red
                : Colors.white10,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.back_hand,
              color: handbrake
                  ? Colors.white
                  : Colors.white54,
            ),

            const SizedBox(height: 5),

            const Text(
              "HANDBRAKE",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonsSection() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        children: [

          const Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "BUTTONS",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              controllerButton("A"),
              controllerButton("B"),
              controllerButton("X"),
              controllerButton("Y"),
            ],
          ),
        ],
      ),
    );
  }

  Widget controllerButton(String text) {
    return GestureDetector(
      onTapDown: (_) {
        // Button press will be sent to PC later.
      },

      child: Container(
        width: 52,
        height: 52,

        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          shape: BoxShape.circle,

          border: Border.all(
            color: Colors.white12,
          ),
        ),

        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void resetController() {
    setState(() {
      steering = 0.0;
      throttle = 0.0;
      brake = 0.0;
      gear = 0;
      handbrake = false;
    });
  }
}