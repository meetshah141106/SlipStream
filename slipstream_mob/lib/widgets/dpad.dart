import 'dart:math' as math;

import 'package:flutter/material.dart';

class Dpad extends StatelessWidget {
  final Set<String> pressedDpad;
  final void Function(String direction) onPressed;
  final void Function(String direction) onReleased;
  final Color surfaceLight;
  final Color blue;

  const Dpad({
    super.key,
    required this.pressedDpad,
    required this.onPressed,
    required this.onReleased,
    required this.surfaceLight,
    required this.blue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final double size = math.min(
          available * 0.95,
          220,
        );

        final double buttonSize = size * 0.34;
        final double center = size / 2;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: center - buttonSize / 2,
                top: 4,
                child: dpadButton(
                  'UP',
                  Icons.keyboard_arrow_up,
                  buttonSize,
                ),
              ),
              Positioned(
                left: 4,
                top: center - buttonSize / 2,
                child: dpadButton(
                  'LEFT',
                  Icons.keyboard_arrow_left,
                  buttonSize,
                ),
              ),
              Positioned(
                right: 4,
                top: center - buttonSize / 2,
                child: dpadButton(
                  'RIGHT',
                  Icons.keyboard_arrow_right,
                  buttonSize,
                ),
              ),
              Positioned(
                left: center - buttonSize / 2,
                bottom: 4,
                child: dpadButton(
                  'DOWN',
                  Icons.keyboard_arrow_down,
                  buttonSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget dpadButton(
    String direction,
    IconData icon,
    double size,
  ) {
    final bool pressed = pressedDpad.contains(direction);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        onPressed(direction);
      },
      onTapUp: (_) {
        onReleased(direction);
      },
      onTapCancel: () {
        onReleased(direction);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: pressed
              ? blue.withOpacity(0.30)
              : surfaceLight,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: pressed
                ? blue
                : Colors.white.withOpacity(0.12),
            width: pressed ? 2 : 1.5,
          ),
          boxShadow: pressed
              ? [
                  BoxShadow(
                    color: blue.withOpacity(0.20),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.42,
            color: pressed ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
