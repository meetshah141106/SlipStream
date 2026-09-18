import 'dart:math' as math;

import 'package:flutter/material.dart';

class RightJoystick extends StatelessWidget {
  final double stickX;
  final double stickY;
  final void Function(Offset localPosition, double size) onChanged;
  final VoidCallback onReleased;
  final Color surface;
  final Color surfaceLight;
  final Color purple;

  const RightJoystick({
    super.key,
    required this.stickX,
    required this.stickY,
    required this.onChanged,
    required this.onReleased,
    required this.surface,
    required this.surfaceLight,
    required this.purple,
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
          available * 0.78,
          150,
        );

        final double travel = size * 0.27;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            onChanged(details.localPosition, size);
          },
          onPanUpdate: (details) {
            onChanged(details.localPosition, size);
          },
          onPanEnd: (_) {
            onReleased();
          },
          onPanCancel: onReleased,
          child: SizedBox(
            width: size,
            height: size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surface,
                border: Border.all(
                  color: purple.withOpacity(0.38),
                  width: 3,
                ),
              ),
              child: Center(
                child: Transform.translate(
                  // stickY uses game convention (up = +1).
                  // Negate to convert to screen coordinates.
                  offset: Offset(
                    stickX * travel,
                    -stickY * travel,
                  ),
                  child: Container(
                    width: size * 0.44,
                    height: size * 0.44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaceLight,
                      border: Border.all(
                        color: Colors.white38,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.gamepad_rounded,
                      color: Colors.white54,
                      size: size * 0.18,
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
}
