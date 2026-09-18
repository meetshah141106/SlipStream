import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:slipstream_mob/services/network_service.dart';

import '../theme/controller_theme.dart';
import '../widgets/abxy_buttons.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/controller_background.dart';
import '../widgets/controller_top_bar.dart';
import '../widgets/dpad.dart';
import '../widgets/pedal_control.dart';
import '../widgets/right_joystick.dart';
import '../widgets/steering_control.dart';

class XboxDrivingController extends StatefulWidget {
  final String controllerName;
  final NetworkService networkService;

  const XboxDrivingController({
    super.key,
    required this.controllerName,
    required this.networkService,
  });

  @override
  State<XboxDrivingController> createState() =>
      _XboxDrivingControllerState();
}

class _XboxDrivingControllerState
    extends State<XboxDrivingController> {
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

  static const double maxSteeringAngle = 40.0;
  static const double steeringMultiplier = 3.0;
  static const double gyroDeadzone = 0.010;
  static const double steeringSmoothing = 0.70;
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

        if (z.abs() < gyroDeadzone) {
          z = 0.0;
        }

        // ========================================================
        // ROTATION
        // ========================================================

        final double degreesPerSecond =
            z * 180.0 / math.pi;

        _gyroAngle += degreesPerSecond * dt;

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

        final double relativeAngle =
            _gyroAngle - _calibrationAngle;

        // ========================================================
        // STEERING
        // ========================================================

        double target =
            (relativeAngle / maxSteeringAngle) *
                steeringMultiplier;

        target = target.clamp(-1.0, 1.0);

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
            'type': 'steering',
            'value': double.parse(
              steering.toStringAsFixed(6),
            ),
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
      'type': 'steering',
      'value': 0.0,
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
      'type': 'steering',
      'value': value,
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
      'type': 'steering',
      'value': 0.0,
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
      if (pedal == 'gas') {
        gas = value;
      } else {
        brake = value;
      }
    });

    send({
      'type': pedal,
      'value': value,
    });
  }

  void releasePedal(String pedal) {
    setState(() {
      if (pedal == 'gas') {
        gas = 0.0;
      } else {
        brake = 0.0;
      }
    });

    send({
      'type': pedal,
      'value': 0.0,
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
      'type': 'button',
      'name': name,
      'pressed': true,
    });
  }

  void buttonReleased(String name) {
    setState(() {
      _pressedButtons.remove(name);
    });

    send({
      'type': 'button',
      'name': name,
      'pressed': false,
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
      'type': 'dpad',
      'direction': direction,
      'pressed': true,
    });
  }

  void dpadReleased(String direction) {
    setState(() {
      _pressedDpad.remove(direction);
    });

    send({
      'type': 'dpad',
      'direction': direction,
      'pressed': false,
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

    const double joystickSensitivity = 1.6;

    final double maxDistance =
        size * 0.20;

    double x =
        (dx / maxDistance) *
            joystickSensitivity;

    double y =
        (-dy / maxDistance) *
            joystickSensitivity;

    x = x.clamp(-1.0, 1.0);
    y = y.clamp(-1.0, 1.0);

    setState(() {
      stickX = x;
      stickY = y;
    });

    send({
      'type': 'right_stick',
      'x': double.parse(
        x.toStringAsFixed(6),
      ),
      'y': double.parse(
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
      'type': 'right_stick',
      'x': 0.0,
      'y': 0.0,
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
      backgroundColor: ControllerTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return Stack(
              children: [
                const Positioned.fill(
                  child: ControllerBackground(),
                ),
                Padding(
                  padding: const EdgeInsets.all(7),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 43,
                        child: ControllerTopBar(
                          pressedButtons: _pressedButtons,
                          onL1Down: () =>
                              buttonPressed('L1'),
                          onL1Up: () =>
                              buttonReleased('L1'),
                          onBackDown: () =>
                              buttonPressed('BACK'),
                          onBackUp: () =>
                              buttonReleased('BACK'),
                          onStartDown: () =>
                              buttonPressed('START'),
                          onStartUp: () =>
                              buttonReleased('START'),
                          onCalibrate: calibrateSteering,
                          onR1Down: () =>
                              buttonPressed('R1'),
                          onR1Up: () =>
                              buttonReleased('R1'),
                          surface: ControllerTheme.surface,
                          blue: ControllerTheme.blue,
                          cyan: ControllerTheme.cyan,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: buildControllerLayout(
                          constraints,
                        ),
                      ),
                    ],
                  ),
                ),
                const ConnectionIndicator(
                  surface: ControllerTheme.surface,
                  gasGreen: ControllerTheme.gasGreen,
                ),
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
                  child: Dpad(
                    pressedDpad: _pressedDpad,
                    onPressed: dpadPressed,
                    onReleased: dpadReleased,
                    surfaceLight:
                        ControllerTheme.surfaceLight,
                    blue: ControllerTheme.blue,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                flex: 6,
                child: Center(
                  child: PedalControl(
                    title: 'BRAKE',
                    value: brake,
                    isBrake: true,
                    onChanged:
                        updatePedalFromPosition,
                    onReleased: releasePedal,
                    surface:
                        ControllerTheme.surface,
                    surfaceDark:
                        ControllerTheme.surfaceDark,
                    brakeRed:
                        ControllerTheme.brakeRed,
                    gasGreen:
                        ControllerTheme.gasGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 7),

        // ========================================================
        // CENTER
        // ========================================================

        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: SteeringControl(
                  steering: steering,
                  gyroEnabled: gyroEnabled,
                  onInteractionStart: () {
                    gyroEnabled = false;
                  },
                  onChanged: updateSteering,
                  onInteractionEnd: resetSteering,
                  surface:
                      ControllerTheme.surface,
                  surfaceDark:
                      ControllerTheme.surfaceDark,
                  blue: ControllerTheme.blue,
                  cyan: ControllerTheme.cyan,
                  racingOrange:
                      ControllerTheme.racingOrange,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                flex: 5,
                child: Center(
                  child: RightJoystick(
                    stickX: stickX,
                    stickY: stickY,
                    onChanged: updateJoystick,
                    onReleased: resetJoystick,
                    surface:
                        ControllerTheme.surface,
                    surfaceLight:
                        ControllerTheme.surfaceLight,
                    purple:
                        ControllerTheme.purple,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 7),

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
                  child: AbxyButtons(
                    pressedButtons: _pressedButtons,
                    onPressed: buttonPressed,
                    onReleased: buttonReleased,
                    surfaceLight:
                        ControllerTheme.surfaceLight,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                flex: 6,
                child: Center(
                  child: PedalControl(
                    title: 'GAS',
                    value: gas,
                    isBrake: false,
                    onChanged:
                        updatePedalFromPosition,
                    onReleased: releasePedal,
                    surface:
                        ControllerTheme.surface,
                    surfaceDark:
                        ControllerTheme.surfaceDark,
                    brakeRed:
                        ControllerTheme.brakeRed,
                    gasGreen:
                        ControllerTheme.gasGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
