import 'dart:math' as math;

import 'package:flutter/material.dart';

class SteeringControl extends StatelessWidget {
  final double steering;
  final bool gyroEnabled;
  final VoidCallback onInteractionStart;
  final void Function(double value) onChanged;
  final VoidCallback onInteractionEnd;
  final Color surface;
  final Color surfaceDark;
  final Color blue;
  final Color cyan;
  final Color racingOrange;

  const SteeringControl({
    super.key,
    required this.steering,
    required this.gyroEnabled,
    required this.onInteractionStart,
    required this.onChanged,
    required this.onInteractionEnd,
    required this.surface,
    required this.surfaceDark,
    required this.blue,
    required this.cyan,
    required this.racingOrange,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final double usableHeight = math.max(
          40,
          height - 38,
        );

        double wheelSize = math.min(
          width * 0.55,
          usableHeight * 0.90,
        );

        wheelSize = math.max(30, wheelSize);

        return GestureDetector(
          onHorizontalDragStart: (_) {
            onInteractionStart();
          },
          onHorizontalDragUpdate: (details) {
            onChanged(
              steering + details.delta.dx / 100,
            );
          },
          onHorizontalDragEnd: (_) {
            onInteractionEnd();
          },
          onHorizontalDragCancel: onInteractionEnd,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: blue.withOpacity(0.16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'STEERING',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        gyroEnabled
                            ? Icons.screen_rotation
                            : Icons.touch_app,
                        color: gyroEnabled
                            ? cyan
                            : racingOrange,
                        size: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Center(
                    child: SizedBox(
                      width: wheelSize,
                      height: wheelSize,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: surfaceDark,
                          border: Border.all(
                            color: const Color(0xFF34485B),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: steering * 0.9,
                            child: Container(
                              width: wheelSize * 0.68,
                              height: wheelSize * 0.68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white54,
                                  width: 5,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: wheelSize * 0.16,
                                  height: wheelSize * 0.16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: racingOrange.withOpacity(0.85),
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
                const SizedBox(height: 1),
                SizedBox(
                  height: 13,
                  child: Text(
                    '${(steering * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
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
}
