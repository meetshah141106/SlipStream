import 'dart:math' as math;

import 'package:flutter/material.dart';

class AbxyButtons extends StatelessWidget {
  final Set<String> pressedButtons;
  final void Function(String name) onPressed;
  final void Function(String name) onReleased;
  final Color surfaceLight;

  const AbxyButtons({
    super.key,
    required this.pressedButtons,
    required this.onPressed,
    required this.onReleased,
    required this.surfaceLight,
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
                  'Y',
                  Colors.amber,
                  buttonSize,
                ),
              ),
              Positioned(
                left: 0,
                top: size / 2 - buttonSize / 2,
                child: gameButton(
                  'X',
                  Colors.blue,
                  buttonSize,
                ),
              ),
              Positioned(
                right: 0,
                top: size / 2 - buttonSize / 2,
                child: gameButton(
                  'B',
                  Colors.red,
                  buttonSize,
                ),
              ),
              Positioned(
                bottom: 0,
                child: gameButton(
                  'A',
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

  Widget gameButton(
    String name,
    Color color,
    double size,
  ) {
    final bool pressed = pressedButtons.contains(name);

    return GestureDetector(
      onTapDown: (_) {
        onPressed(name);
      },
      onTapUp: (_) {
        onReleased(name);
      },
      onTapCancel: () {
        onReleased(name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pressed
              ? color.withOpacity(0.28)
              : surfaceLight,
          border: Border.all(
            color: pressed
                ? color
                : color.withOpacity(0.65),
            width: pressed ? 2.5 : 2,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: pressed ? Colors.white : color,
              fontSize: size * 0.34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
