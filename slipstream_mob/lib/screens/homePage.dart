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

  // ============================================================
  // COLORS
  // ============================================================

  static const Color background =
      Color(0xFF0A0F1F);

  static const Color surface =
      Color(0xFF141C30);

  static const Color surfaceLight =
      Color(0xFF202A43);

  static const Color primaryBlue =
      Color(0xFF5B8DEF);

  static const Color purple =
      Color(0xFF8B6FF7);

  static const Color cyan =
      Color(0xFF43D9FF);

  static const Color orange =
      Color(0xFFFF9A52);

  static const Color green =
      Color(0xFF45D19A);

  static const Color red =
      Color(0xFFFF6670);

  static const Color textPrimary =
      Color(0xFFF5F7FF);

  static const Color textSecondary =
      Color(0xFFAAB4CC);

  // ============================================================
  // CONNECTION
  // ============================================================

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connected
              ? "Connected to PC"
              : "Could not connect to PC",
        ),
      ),
    );
  }

  // ============================================================
  // OPEN CONTROLLER
  // ============================================================

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
        builder: (context) => DriveController(
          controllerName: controllerName,
          networkService: networkService,
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    ipController.dispose();
    networkService.disconnect();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            35,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                        colors: [
                          primaryBlue,
                          purple,
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue
                              .withOpacity(
                            0.22,
                          ),
                          blurRadius: 16,
                          offset:
                              const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons
                          .sports_esports_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          "SlipStream",
                          style: TextStyle(
                            color:
                                textPrimary,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing:
                                -0.5,
                          ),
                        ),

                        SizedBox(
                          height: 2,
                        ),

                        Text(
                          "Your phone. Your controller.",
                          style: TextStyle(
                            color:
                                textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // CONNECTION STATUS
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),

                    decoration:
                        BoxDecoration(
                      color: isConnected
                          ? green.withOpacity(
                              0.10,
                            )
                          : surface,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                      border: Border.all(
                        color: isConnected
                            ? green.withOpacity(
                                0.25,
                              )
                            : Colors.white
                                .withOpacity(
                                0.07,
                              ),
                      ),
                    ),

                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        Container(
                          width: 7,
                          height: 7,

                          decoration:
                              BoxDecoration(
                            color:
                                isConnected
                                    ? green
                                    : textSecondary,
                            shape:
                                BoxShape.circle,
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Text(
                          isConnected
                              ? "Connected"
                              : "Offline",

                          style: TextStyle(
                            color:
                                isConnected
                                    ? green
                                    : textSecondary,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 40,
              ),

              // ==================================================
              // HERO
              // ==================================================

              ShaderMask(
                shaderCallback:
                    (bounds) {
                  return const LinearGradient(
                    colors: [
                      primaryBlue,
                      purple,
                      cyan,
                    ],
                  ).createShader(
                    Rect.fromLTWH(
                      0,
                      0,
                      bounds.width,
                      bounds.height,
                    ),
                  );
                },

                child: const Text(
                  "Your games.\nYour way.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: -1.3,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                "Connect your PC and choose the controller\nthat fits what you want to play.",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // CONNECTION CARD
              // ==================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(20),

                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      Color(0xFF19233B),
                      Color(0xFF121A2D),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),

                  border: Border.all(
                    color: primaryBlue
                        .withOpacity(
                      0.14,
                    ),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue
                          .withOpacity(
                        0.06,
                      ),
                      blurRadius: 30,
                      offset:
                          const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // CARD HEADER
                    // ==================================================

                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,

                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              colors: [
                                primaryBlue
                                    .withOpacity(
                                  0.20,
                                ),
                                cyan.withOpacity(
                                  0.10,
                                ),
                              ],
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              13,
                            ),
                          ),

                          child: const Icon(
                            Icons
                                .laptop_mac_rounded,
                            color:
                                primaryBlue,
                            size: 22,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                "Connect your PC",
                                style:
                                    TextStyle(
                                  color:
                                      textPrimary,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              SizedBox(
                                height: 3,
                              ),

                              Text(
                                "Same local network",
                                style:
                                    TextStyle(
                                  color:
                                      textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 21,
                    ),

                    const Text(
                      "PC IP ADDRESS",
                      style: TextStyle(
                        color:
                            textSecondary,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ==================================================
                    // IP INPUT
                    // ==================================================

                    TextField(
                      controller:
                          ipController,

                      enabled:
                          !isConnected,

                      keyboardType:
                          TextInputType.number,

                      style:
                          const TextStyle(
                        color:
                            textPrimary,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),

                      cursorColor:
                          primaryBlue,

                      decoration:
                          InputDecoration(
                        hintText:
                            "192.168.1.38",

                        hintStyle:
                            TextStyle(
                          color:
                              textSecondary
                                  .withOpacity(
                            0.55,
                          ),
                        ),

                        filled: true,

                        fillColor:
                            const Color(
                          0xFF0D1425,
                        ),

                        prefixIcon:
                            const Icon(
                          Icons
                              .lan_outlined,
                          color:
                              textSecondary,
                          size: 20,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              BorderSide
                                  .none,
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              BorderSide(
                            color: Colors
                                .white
                                .withOpacity(
                              0.06,
                            ),
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          borderSide:
                              const BorderSide(
                            color:
                                primaryBlue,
                            width: 1.3,
                          ),
                        ),

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // CONNECT BUTTON
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,

                      child:
                          ElevatedButton(
                        onPressed:
                            isConnecting
                                ? null
                                : toggleConnection,

                        style:
                            ElevatedButton
                                .styleFrom(
                          elevation: 0,

                          backgroundColor:
                              Colors.transparent,

                          foregroundColor:
                              Colors.white,

                          shadowColor:
                              Colors.transparent,

                          padding:
                              EdgeInsets.zero,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),

                        child: Ink(
                          width:
                              double.infinity,
                          height: 52,

                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin:
                                  Alignment
                                      .centerLeft,
                              end:
                                  Alignment
                                      .centerRight,
                              colors:
                                  isConnected
                                      ? [
                                          const Color(
                                            0xFF522733,
                                          ),
                                          const Color(
                                            0xFF3A202A,
                                          ),
                                        ]
                                      : [
                                          primaryBlue,
                                          purple,
                                        ],
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),

                          child:
                              Center(
                            child:
                                isConnecting
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2.2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,

                                        children: [
                                          Icon(
                                            isConnected
                                                ? Icons
                                                    .link_off_rounded
                                                : Icons
                                                    .link_rounded,
                                            size: 19,
                                          ),

                                          const SizedBox(
                                            width: 8,
                                          ),

                                          Text(
                                            isConnected
                                                ? "Disconnect"
                                                : "Connect to PC",

                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  14,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ],
                                      ),
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // CONNECTED INFO
                    // ==================================================

                    if (isConnected) ...[
                      const SizedBox(
                        height: 14,
                      ),

                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),

                        decoration:
                            BoxDecoration(
                          color: green
                              .withOpacity(
                            0.08,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),

                          border: Border.all(
                            color: green
                                .withOpacity(
                              0.12,
                            ),
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .check_circle_rounded,
                              color: green,
                              size: 18,
                            ),

                            const SizedBox(
                              width: 9,
                            ),

                            Expanded(
                              child:
                                  Text(
                                "Connected to ${ipController.text}",
                                style:
                                    const TextStyle(
                                  color:
                                      green,
                                  fontSize:
                                      12,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                height: 34,
              ),

              // ==================================================
              // CONTROLLERS HEADER
              // ==================================================

              const Text(
                "Controllers",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              const Text(
                "Pick a layout for what you're playing.",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // GAME CONTROLLER
              // ==================================================

              controllerCard(
                icon: Icons
                    .sports_esports_rounded,

                title:
                    "Game Controller",

                subtitle:
                    "Buttons • D-pad • Joysticks",

                accent:
                    purple,

                secondAccent:
                    cyan,

                onTap: () {
                  openController(
                    "Game Controller",
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // RACING CONTROLLER
              // ==================================================

              controllerCard(
                icon: Icons
                    .sports_motorsports_rounded,

                title:
                    "Racing Controller",

                subtitle:
                    "Steering • Throttle • Brake",

                accent:
                    orange,

                secondAccent:
                    const Color(
                  0xFFFFC16B,
                ),

                onTap: () {
                  openController(
                    "Racing Controller",
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // MORE CONTROLLERS
              // ==================================================

              controllerCard(
                icon:
                    Icons.add_rounded,

                title:
                    "More Controllers",

                subtitle:
                    "More layouts coming soon",

                accent:
                    cyan,

                secondAccent:
                    primaryBlue,

                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "More controller layouts are coming soon.",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // FOOTER
              // ==================================================

              Center(
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.wifi_rounded,
                      color: textSecondary
                          .withOpacity(
                        0.75,
                      ),
                      size: 14,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      "Local connection • No internet required",
                      style: TextStyle(
                        color:
                            textSecondary
                                .withOpacity(
                          0.70,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTROLLER CARD
  // ============================================================

  Widget controllerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required Color secondAccent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(20),

        child: Ink(
          width:
              double.infinity,

          padding:
              const EdgeInsets.all(17),

          decoration:
              BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                surface,
                Color.lerp(
                  surface,
                  accent,
                  0.08,
                )!,
              ],
            ),

            borderRadius:
                BorderRadius.circular(
              20,
            ),

            border: Border.all(
              color: accent.withOpacity(
                0.13,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(
                  0.045,
                ),
                blurRadius: 20,
                offset:
                    const Offset(0, 7),
              ),
            ],
          ),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 55,
                height: 55,

                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      accent.withOpacity(
                        0.20,
                      ),
                      secondAccent
                          .withOpacity(
                        0.08,
                      ),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Icon(
                  icon,
                  color: accent,
                  size: 28,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              // ==================================================
              // TEXT
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,

                      style:
                          const TextStyle(
                        color:
                            textPrimary,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      subtitle,

                      style:
                          const TextStyle(
                        color:
                            textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ARROW
              // ==================================================

              Container(
                width: 35,
                height: 35,

                decoration:
                    BoxDecoration(
                  color: accent
                      .withOpacity(
                    0.09,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),

                child: Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color: accent
                      .withOpacity(
                    0.85,
                  ),
                  size: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}