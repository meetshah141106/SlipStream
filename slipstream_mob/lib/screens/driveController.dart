import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:slipstream_mob/services/network_service.dart';

class DriveController extends StatefulWidget {
  final String controllerName;
  final NetworkService networkService;

  const DriveController({
    super.key,
    required this.controllerName,
    required this.networkService,
  });

  @override
  State<DriveController> createState() => _DriveControllerState();
}

class _DriveControllerState extends State<DriveController> {
  // ============================================================
  // CONTROLLER VALUES
  // ============================================================

  double steering = 0.0;
  double gas = 0.0;
  double brake = 0.0;

  double stickX = 0.0;
  double stickY = 0.0;

  // ============================================================
  // PRESSED STATES
  // ============================================================

  final Set<String> _pressedButtons = {};
  final Set<String> _pressedDpad = {};

  // ============================================================
  // GYRO
  // ============================================================

  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  bool gyroEnabled = true;

  double _gyroAngle = 0.0;
  double _calibrationAngle = 0.0;

  DateTime? _lastGyroTime;
  DateTime _lastSteeringSend = DateTime.now();

  // ============================================================
  // GYRO SETTINGS
  // ============================================================

// Lower = more sensitive.
static const double maxSteeringAngle = 40.0;

// Higher = more steering for the same physical movement.
static const double steeringMultiplier = 3.0;

// Small gyro noise filter.
static const double gyroDeadzone = 0.010;

// Higher = faster response / less delay.
static const double steeringSmoothing = 0.70;

// Ignore abnormal sensor gaps.
static const double maxSensorDelta = 0.10;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    startGyroscope();
  }

  // ============================================================
  // GYROSCOPE
  // ============================================================

  void startGyroscope() {
  _gyroSubscription?.cancel();

  _lastGyroTime = null;

  _gyroSubscription = gyroscopeEventStream(
    samplingPeriod: SensorInterval.gameInterval,
  ).listen(
    (GyroscopeEvent event) {
      if (!gyroEnabled) {
        _lastGyroTime = null;
        return;
      }

      final DateTime now = DateTime.now();

      if (_lastGyroTime == null) {
        _lastGyroTime = now;
        return;
      }

      final double dt =
          now.difference(_lastGyroTime!).inMicroseconds /
              1000000.0;

      _lastGyroTime = now;

      if (dt <= 0 || dt > maxSensorDelta) {
        return;
      }

      // ========================================================
      // GYRO DIRECTION
      // ========================================================

      double z = -event.z;

      // Remove tiny sensor noise.
      if (z.abs() < gyroDeadzone) {
        z = 0.0;
      }

      // ========================================================
      // ROTATION
      // ========================================================

      final double degreesPerSecond =
          z * 180.0 / math.pi;

      _gyroAngle += degreesPerSecond * dt;

      // Keep the angle from becoming extremely large,
      // WITHOUT changing the calibration reference.
      if (_gyroAngle > 10000.0) {
        _gyroAngle -= 10000.0;
        _calibrationAngle -= 10000.0;
      } else if (_gyroAngle < -10000.0) {
        _gyroAngle += 10000.0;
        _calibrationAngle += 10000.0;
      }

      // ========================================================
      // CALIBRATION
      // ========================================================

      // IMPORTANT:
      // _calibrationAngle does NOT change here.
      //
      // It only changes when the user presses CALIBRATE.

      final double relativeAngle =
          _gyroAngle - _calibrationAngle;

      // ========================================================
      // STEERING
      // ========================================================

      double target =
          (relativeAngle / maxSteeringAngle) *
              steeringMultiplier;

      target = target.clamp(-1.0, 1.0);

      // Fast response.
      steering +=
          (target - steering) *
              steeringSmoothing;

      steering = steering.clamp(-1.0, 1.0);

      // ========================================================
      // SEND
      // ========================================================

      if (now
              .difference(_lastSteeringSend)
              .inMilliseconds >=
          20) {
        _lastSteeringSend = now;

        send({
          "type": "steering",
          "value": double.parse(steering.toStringAsFixed(6)),
        });

        if (mounted) {
          setState(() {});
        }
      }
    },
    onError: (_) {
      if (!mounted) return;

      setState(() {
        gyroEnabled = false;
      });
    },
  );
}

  // ============================================================
  // CALIBRATION
  // ============================================================

  void calibrateSteering() {
    _calibrationAngle = _gyroAngle;

    _lastGyroTime = DateTime.now();

    setState(() {
      steering = 0.0;
      gyroEnabled = true;
    });

    send({
      "type": "steering",
      "value": 0.0,
    });
  }

  // ============================================================
  // NETWORK
  // ============================================================

  void send(Map<String, dynamic> data) {
    widget.networkService.send(
      jsonEncode(data),
    );
  }

  // ============================================================
  // TOUCH STEERING
  // ============================================================

  void updateSteering(double value) {
    gyroEnabled = false;

    value = value.clamp(
      -1.0,
      1.0,
    );

    setState(() {
      steering = value;
    });

    send({
      "type": "steering",
      "value": value,
    });
  }

  void resetSteering() {
    _calibrationAngle = _gyroAngle;

    _lastGyroTime = DateTime.now();

    setState(() {
      steering = 0.0;
      gyroEnabled = true;
    });

    send({
      "type": "steering",
      "value": 0.0,
    });
  }

  // ============================================================
  // PEDALS
  // ============================================================

  void updatePedalFromPosition(
    String pedal,
    double localY,
    double height,
  ) {
    if (height <= 0) return;

    double value =
        1.0 - (localY / height);

    value = value.clamp(
      0.0,
      1.0,
    );

    setState(() {
      if (pedal == "gas") {
        gas = value;
      } else {
        brake = value;
      }
    });

    send({
      "type": pedal,
      "value": value,
    });
  }

  void releasePedal(String pedal) {
    setState(() {
      if (pedal == "gas") {
        gas = 0.0;
      } else {
        brake = 0.0;
      }
    });

    send({
      "type": pedal,
      "value": 0.0,
    });
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  void buttonPressed(String name) {
    setState(() {
      _pressedButtons.add(name);
    });

    send({
      "type": "button",
      "name": name,
      "pressed": true,
    });
  }

  void buttonReleased(String name) {
    setState(() {
      _pressedButtons.remove(name);
    });

    send({
      "type": "button",
      "name": name,
      "pressed": false,
    });
  }

  // ============================================================
  // D-PAD
  // ============================================================

  void dpadPressed(String direction) {
    setState(() {
      _pressedDpad.add(direction);
    });

    send({
      "type": "dpad",
      "direction": direction,
      "pressed": true,
    });
  }

  void dpadReleased(String direction) {
    setState(() {
      _pressedDpad.remove(direction);
    });

    send({
      "type": "dpad",
      "direction": direction,
      "pressed": false,
    });
  }

  // ============================================================
  // JOYSTICK
  // ============================================================

  void updateJoystick(
  Offset localPosition,
  double size,
) {
  final Offset center = Offset(
    size / 2,
    size / 2,
  );

  final double dx =
      localPosition.dx - center.dx;

  final double dy =
      localPosition.dy - center.dy;

  // Higher = more sensitive.
  const double joystickSensitivity = 1.6;

  // Lower = less physical movement required
  // to reach maximum input.
  final double maxDistance = size * 0.20;

  double x =
      (dx / maxDistance) *
          joystickSensitivity;

  double y =
      (dy / maxDistance) *
          joystickSensitivity;

  x = x.clamp(-1.0, 1.0);
  y = y.clamp(-1.0, 1.0);

  setState(() {
    stickX = x;
    stickY = y;
  });

  // SEND JOYSTICK INPUT TO PC
  send({
    "type": "right_stick",
    "x": double.parse(
      x.toStringAsFixed(6),
    ),
    "y": double.parse(
      y.toStringAsFixed(6),
    ),
  });
}

  void resetJoystick() {
  setState(() {
    stickX = 0.0;
    stickY = 0.0;
  });

  send({
    "type": "right_stick",
    "x": 0.0,
    "y": 0.0,
  });
}

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _gyroSubscription?.cancel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF08111A),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return Stack(
              children: [
                const Positioned.fill(
                  child: _Background(),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(6),

                  child: Column(
                    children: [
                      SizedBox(
                        height: 44,
                        child:
                            buildTopBar(),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Expanded(
                        child:
                            buildControllerLayout(
                          constraints,
                        ),
                      ),
                    ],
                  ),
                ),

                buildConnectionIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CONTROLLER LAYOUT
  // ============================================================

  Widget buildControllerLayout(
    BoxConstraints constraints,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        // ========================================================
        // LEFT
        // ========================================================

        Expanded(
          flex: 3,

          child: Column(
            children: [
              Expanded(
                flex: 5,

                child: Center(
                  child: dpad(),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Expanded(
                flex: 6,

                child: Center(
                  child: pedal(
                    title: "BRAKE",
                    value: brake,
                    isBrake: true,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 6,
        ),

        // ========================================================
        // CENTER
        // ========================================================

        Expanded(
          flex: 5,

          child: Column(
            children: [
              Expanded(
                flex: 5,

                child:
                    steeringControl(),
              ),

              const SizedBox(
                height: 4,
              ),

              Expanded(
                flex: 5,

                child: Center(
                  child:
                      rightJoystick(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 6,
        ),

        // ========================================================
        // RIGHT
        // ========================================================

        Expanded(
          flex: 3,

          child: Column(
            children: [
              Expanded(
                flex: 5,

                child: Center(
                  child: abxy(),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Expanded(
                flex: 6,

                child: Center(
                  child: pedal(
                    title: "GAS",
                    value: gas,
                    isBrake: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget buildTopBar() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,

      children: [
        controllerTopButton(
          "L1",
          () => buttonPressed("L1"),
          () => buttonReleased("L1"),
        ),

        const SizedBox(
          width: 7,
        ),

        smallTopButton(
          Icons.arrow_back,
          "Back",
          () => buttonPressed("BACK"),
          () => buttonReleased("BACK"),
        ),

        const SizedBox(
          width: 7,
        ),

        smallTopButton(
          Icons.play_arrow,
          "Start",
          () => buttonPressed("START"),
          () => buttonReleased("START"),
        ),

        const SizedBox(
          width: 7,
        ),

        GestureDetector(
          onTap: calibrateSteering,

          child: Container(
            height: 38,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(0xFF16222D),

              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              border: Border.all(
                color:
                    const Color(0xFF344553),
              ),
            ),

            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Icon(
                  Icons.center_focus_strong,
                  color:
                      Colors.white54,
                  size: 15,
                ),

                SizedBox(
                  width: 5,
                ),

                Text(
                  "CALIBRATE",

                  style:
                      TextStyle(
                    color:
                        Colors.white60,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        controllerTopButton(
          "R1",
          () => buttonPressed("R1"),
          () => buttonReleased("R1"),
        ),
      ],
    );
  }

  // ============================================================
  // L1 / R1
  // ============================================================

  Widget controllerTopButton(
    String text,
    VoidCallback onDown,
    VoidCallback onUp,
  ) {
    final bool pressed =
        _pressedButtons.contains(text);

    return SizedBox(
      width: 60,

      child: GestureDetector(
        onTapDown: (_) => onDown(),
        onTapUp: (_) => onUp(),
        onTapCancel: onUp,

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 70,
          ),

          height: 40,

          decoration:
              BoxDecoration(
            color: pressed
                ? const Color(
                    0xFF304653,
                  )
                : const Color(
                    0xFF16222D,
                  ),

            borderRadius:
                BorderRadius.circular(
              11,
            ),

            border: Border.all(
              color: pressed
                  ? Colors.white54
                  : const Color(
                      0xFF344553,
                    ),

              width:
                  pressed ? 2 : 1,
            ),

            boxShadow: pressed
                ? [
                    BoxShadow(
                      color:
                          Colors.white
                              .withOpacity(
                        0.18,
                      ),

                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),

          child: Center(
            child: Text(
              text,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BACK / START
  // ============================================================

  Widget smallTopButton(
    IconData icon,
    String label,
    VoidCallback onDown,
    VoidCallback onUp,
  ) {
    final String buttonName =
        label == "Back"
            ? "BACK"
            : "START";

    final bool pressed =
        _pressedButtons.contains(
      buttonName,
    );

    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,

      child: SizedBox(
        width: 45,
        height: 42,

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 70,
              ),

              width: 45,
              height: 32,

              decoration:
                  BoxDecoration(
                color: pressed
                    ? const Color(
                        0xFF304653,
                      )
                    : const Color(
                        0xFF16222D,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  9,
                ),

                border: Border.all(
                  color: pressed
                      ? Colors.white54
                      : const Color(
                          0xFF344553,
                        ),

                  width:
                      pressed ? 2 : 1,
                ),

                boxShadow: pressed
                    ? [
                        BoxShadow(
                          color: Colors.white
                              .withOpacity(
                            0.18,
                          ),

                          blurRadius: 9,
                        ),
                      ]
                    : [],
              ),

              child: Center(
                child: Icon(
                  icon,

                  color: pressed
                      ? Colors.white
                      : Colors.white70,

                  size: 19,
                ),
              ),
            ),

            const SizedBox(
              height: 1,
            ),

            SizedBox(
              height: 8,

              child: Text(
                label,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      Colors.white38,
                  fontSize: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEERING
  // ============================================================

  Widget steeringControl() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final double width =
            constraints.maxWidth;

        final double height =
            constraints.maxHeight;

        final double usableHeight =
            math.max(
          40,
          height - 38,
        );

        double wheelSize =
            math.min(
          width * 0.55,
          usableHeight * 0.90,
        );

        wheelSize = math.max(
          30,
          wheelSize,
        );

        return GestureDetector(
          onHorizontalDragStart: (_) {
            gyroEnabled = false;
          },

          onHorizontalDragUpdate:
              (details) {
            updateSteering(
              steering +
                  details.delta.dx /
                      100,
            );
          },

          onHorizontalDragEnd: (_) {
            resetSteering();
          },

          onHorizontalDragCancel:
              resetSteering,

          child: Container(
            width: double.infinity,
            height: double.infinity,

            margin:
                const EdgeInsets.symmetric(
              horizontal: 2,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(0xFF111B24),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              border: Border.all(
                color:
                    const Color(0xFF304452),
              ),
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                SizedBox(
                  height: 15,

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      const Text(
                        "STEERING",

                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Icon(
                        gyroEnabled
                            ? Icons
                                .screen_rotation
                            : Icons
                                .touch_app,

                        color:
                            Colors.white38,

                        size: 12,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Flexible(
                  child: Center(
                    child: SizedBox(
                      width: wheelSize,
                      height: wheelSize,

                      child: Container(
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,

                          color:
                              const Color(
                            0xFF16222D,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFF4D6270,
                            ),

                            width: 3,
                          ),
                        ),

                        child: Center(
                          child:
                              Transform.rotate(
                            angle:
                                steering *
                                    0.9,

                            child:
                                Container(
                              width:
                                  wheelSize *
                                      0.68,

                              height:
                                  wheelSize *
                                      0.68,

                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape
                                        .circle,

                                border:
                                    Border.all(
                                  color:
                                      Colors
                                          .white54,

                                  width: 5,
                                ),
                              ),

                              child: Center(
                                child:
                                    Container(
                                  width:
                                      wheelSize *
                                          0.16,

                                  height:
                                      wheelSize *
                                          0.16,

                                  decoration:
                                      const BoxDecoration(
                                    shape:
                                        BoxShape
                                            .circle,

                                    color:
                                        Colors
                                            .white24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 1,
                ),

                SizedBox(
                  height: 13,

                  child: Text(
                    "${(steering * 100).round()}%",

                    style:
                        const TextStyle(
                      color:
                          Colors.white54,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PEDAL
  // ============================================================

  Widget pedal({
    required String title,
    required double value,
    required bool isBrake,
  }) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final double width =
            math.min(
          constraints.maxWidth * 0.58,
          115,
        );

        final double height =
            constraints.maxHeight;

        return GestureDetector(
          behavior:
              HitTestBehavior.opaque,

          onPanStart: (details) {
            updatePedalFromPosition(
              isBrake
                  ? "brake"
                  : "gas",
              details.localPosition.dy,
              height,
            );
          },

          onPanUpdate: (details) {
            updatePedalFromPosition(
              isBrake
                  ? "brake"
                  : "gas",
              details.localPosition.dy,
              height,
            );
          },

          onPanEnd: (_) {
            releasePedal(
              isBrake
                  ? "brake"
                  : "gas",
            );
          },

          onPanCancel: () {
            releasePedal(
              isBrake
                  ? "brake"
                  : "gas",
            );
          },

          child: Container(
            width: width,
            height: height,

            decoration:
                BoxDecoration(
              color:
                  const Color(0xFF111B24),

              borderRadius:
                  BorderRadius.circular(
                width / 2,
              ),

              border: Border.all(
                color: isBrake
                    ? const Color(
                        0xFF77494D,
                      )
                    : const Color(
                        0xFF41664E,
                      ),

                width: 2,
              ),
            ),

            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),

                Text(
                  title,

                  style: TextStyle(
                    color: isBrake
                        ? Colors.red.shade200
                        : Colors.green.shade200,

                    fontSize: 9,

                    fontWeight:
                        FontWeight.bold,

                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Expanded(
                  child: Container(
                    width: 30,

                    margin:
                        const EdgeInsets.only(
                      bottom: 4,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF080D12,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),

                      border: Border.all(
                        color:
                            Colors.white12,
                      ),
                    ),

                    child: Stack(
                      alignment:
                          Alignment.bottomCenter,

                      children: [
                        FractionallySizedBox(
                          heightFactor:
                              value,

                          widthFactor: 1,

                          child:
                              Container(
                            decoration:
                                BoxDecoration(
                              color: isBrake
                                  ? Colors.red
                                      .withOpacity(
                                      0.45,
                                    )
                                  : Colors.green
                                      .withOpacity(
                                      0.45,
                                    ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment:
                              Alignment(
                            0,
                            1 -
                                (value * 2),
                          ),

                          child:
                              Container(
                            width: 22,
                            height: 22,

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape
                                      .circle,

                              color: isBrake
                                  ? Colors
                                      .red
                                      .shade300
                                  : Colors
                                      .green
                                      .shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Text(
                  "${(value * 100).round()}%",

                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 9,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // D-PAD
  // ============================================================

  Widget dpad() {
  return LayoutBuilder(
    builder: (
      context,
      constraints,
    ) {
      final double available = math.min(
        constraints.maxWidth,
        constraints.maxHeight,
      );

      final double size = math.min(
        available * 0.88,
        190,
      );

      final double buttonSize = math.min(
        size * 0.34,
        64,
      );

      final double center =
          size / 2;

      return SizedBox(
        width: size,
        height: size,

        child: Stack(
          alignment: Alignment.center,

          children: [
            // ----------------------------------------------------
            // CENTER
            // ----------------------------------------------------

            Container(
              width: buttonSize,
              height: buttonSize,

              decoration: BoxDecoration(
                color: const Color(
                  0xFF17232D,
                ),

                borderRadius:
                    BorderRadius.circular(8),

                border: Border.all(
                  color: const Color(
                    0xFF344553,
                  ),
                  width: 1.5,
                ),
              ),
            ),

            // ----------------------------------------------------
            // UP
            // ----------------------------------------------------

            Positioned(
              left:
                  center -
                  buttonSize / 2,

              top:
                  center -
                  buttonSize * 1.5,

              child: dpadButton(
                "UP",
                Icons.keyboard_arrow_up,
                buttonSize,
              ),
            ),

            // ----------------------------------------------------
            // DOWN
            // ----------------------------------------------------

            Positioned(
              left:
                  center -
                  buttonSize / 2,

              top:
                  center +
                  buttonSize * 0.5,

              child: dpadButton(
                "DOWN",
                Icons.keyboard_arrow_down,
                buttonSize,
              ),
            ),

            // ----------------------------------------------------
            // LEFT
            // ----------------------------------------------------

            Positioned(
              left:
                  center -
                  buttonSize * 1.5,

              top:
                  center -
                  buttonSize / 2,

              child: dpadButton(
                "LEFT",
                Icons.keyboard_arrow_left,
                buttonSize,
              ),
            ),

            // ----------------------------------------------------
            // RIGHT
            // ----------------------------------------------------

            Positioned(
              left:
                  center +
                  buttonSize * 0.5,

              top:
                  center -
                  buttonSize / 2,

              child: dpadButton(
                "RIGHT",
                Icons.keyboard_arrow_right,
                buttonSize,
              ),
            ),
          ],
        ),
      );
    },
  );
}
  // ============================================================
  // D-PAD BUTTON
  // ============================================================

  Widget dpadButton(
    String direction,
    IconData icon,
    double size,
  ) {
    final bool pressed =
        _pressedDpad.contains(
      direction,
    );

    return GestureDetector(
      onTapDown: (_) {
        dpadPressed(direction);
      },

      onTapUp: (_) {
        dpadReleased(direction);
      },

      onTapCancel: () {
        dpadReleased(direction);
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 70,
        ),

        width: size,
        height: size,

        decoration:
            BoxDecoration(
          color: pressed
              ? const Color(
                  0xFF304653,
                )
              : const Color(
                  0xFF17232D,
                ),

          borderRadius:
              BorderRadius.circular(
            12,
          ),

          border: Border.all(
            color: pressed
                ? Colors.white70
                : const Color(
                    0xFF344553,
                  ),

            width:
                pressed ? 2.5 : 1.5,
          ),

          boxShadow: pressed
              ? [
                  BoxShadow(
                    color:
                        Colors.white
                            .withOpacity(
                      0.20,
                    ),

                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),

        child: Center(
          child: Icon(
            icon,

            color: pressed
                ? Colors.white
                : Colors.white70,

            size:
                size * 0.55,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // A B X Y
  // ============================================================

  Widget abxy() {
  return LayoutBuilder(
    builder: (
      context,
      constraints,
    ) {
      final double available = math.min(
        constraints.maxWidth,
        constraints.maxHeight,
      );

      final double size = math.min(
        available * 0.95,
        200,
      );

      final double buttonSize = math.min(
        size * 0.40,
        72,
      );

      return SizedBox(
        width: size,
        height: size,

        child: Stack(
          alignment: Alignment.center,

          children: [
            Positioned(
              top: 0,

              child: gameButton(
                "Y",
                Colors.amber,
                buttonSize,
              ),
            ),

            Positioned(
              left: 0,

              top:
                  size / 2 -
                  buttonSize / 2,

              child: gameButton(
                "X",
                Colors.blue,
                buttonSize,
              ),
            ),

            Positioned(
              right: 0,

              top:
                  size / 2 -
                  buttonSize / 2,

              child: gameButton(
                "B",
                Colors.red,
                buttonSize,
              ),
            ),

            Positioned(
              bottom: 0,

              child: gameButton(
                "A",
                Colors.green,
                buttonSize,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  // ============================================================
  // GAME BUTTON
  // ============================================================

  Widget gameButton(
    String name,
    Color color,
    double size,
  ) {
    final bool pressed =
        _pressedButtons.contains(
      name,
    );

    return GestureDetector(
      onTapDown: (_) {
        buttonPressed(name);
      },

      onTapUp: (_) {
        buttonReleased(name);
      },

      onTapCancel: () {
        buttonReleased(name);
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 70,
        ),

        width: size,
        height: size,

        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,

          color: pressed
              ? color.withOpacity(
                  0.32,
                )
              : const Color(
                  0xFF17232D,
                ),

          border: Border.all(
            color: pressed
                ? color
                : color.withOpacity(
                    0.70,
                  ),

            width:
                pressed ? 3 : 2,
          ),

          boxShadow: pressed
              ? [
                  BoxShadow(
                    color:
                        color.withOpacity(
                      0.45,
                    ),

                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),

        child: Center(
          child: Text(
            name,

            style: TextStyle(
              color: pressed
                  ? Colors.white
                  : color,

              fontSize:
                  size * 0.34,

              fontWeight:
                  FontWeight.bold,

              shadows: pressed
                  ? [
                      Shadow(
                        color: color,
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RIGHT JOYSTICK
  // ============================================================

  Widget rightJoystick() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final double available =
            math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final double size =
            math.min(
          available * 0.78,
          150,
        );

        final double travel =
            size * 0.27;

        return GestureDetector(
          behavior:
              HitTestBehavior.opaque,

          onPanStart: (details) {
            updateJoystick(
              details.localPosition,
              size,
            );
          },

          onPanUpdate: (details) {
            updateJoystick(
              details.localPosition,
              size,
            );
          },

          onPanEnd: (_) {
            resetJoystick();
          },

          onPanCancel:
              resetJoystick,

          child: SizedBox(
            width: size,
            height: size,

            child: Container(
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color:
                    const Color(
                  0xFF111B24,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFF435867,
                  ),

                  width: 3,
                ),
              ),

              child: Center(
                child:
                    Transform.translate(
                  offset: Offset(
                    stickX * travel,
                    stickY * travel,
                  ),

                  child:
                      Container(
                    width:
                        size * 0.44,

                    height:
                        size * 0.44,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      color:
                          const Color(
                        0xFF1C2A35,
                      ),

                      border:
                          Border.all(
                        color:
                            Colors.white38,

                        width: 3,
                      ),
                    ),

                    child: Icon(
                      Icons.gamepad,

                      color:
                          Colors.white54,

                      size:
                          size * 0.18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONNECTION INDICATOR
  // ============================================================

  Widget buildConnectionIndicator() {
    return Positioned(
      right: 8,
      bottom: 5,

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(0xFF111B24),

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color:
                Colors.white10,
          ),
        ),

        child: const Row(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons.circle,
              color: Colors.green,
              size: 6,
            ),

            SizedBox(
              width: 4,
            ),

            Text(
              "CONNECTED",

              style:
                  TextStyle(
                color:
                    Colors.white60,
                fontSize: 8,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// BACKGROUND
// ================================================================

class _Background
    extends StatelessWidget {
  const _Background();

  @override
  Widget build(
    BuildContext context,
  ) {
    return CustomPaint(
      painter:
          _BackgroundPainter(),
    );
  }
}

class _BackgroundPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color =
          const Color(0xFF0D1822)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1;

    for (
      double x = -size.height;
      x < size.width;
      x += 100
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          x + size.height,
          size.height,
        ),
        paint,
      );
    }

    paint.color =
        const Color(0xFF16242F);

    for (
      double y = 0;
      y < size.height;
      y += 70
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width,
          y,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {
    return false;
  }
}
