import 'dart:math' as math;

import 'package:flutter/material.dart';

class PedalControl extends StatelessWidget {
  final String title;
  final double value;
  final bool isBrake;
  final void Function(String pedal, double localY, double height) onChanged;
  final void Function(String pedal) onReleased;
  final Color surface;
  final Color surfaceDark;
  final Color brakeRed;
  final Color gasGreen;

  const PedalControl({
    super.key,
    required this.title,
    required this.value,
    required this.isBrake,
    required this.onChanged,
    required this.onReleased,
    required this.surface,
    required this.surfaceDark,
    required this.brakeRed,
    required this.gasGreen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = math.min(
          constraints.maxWidth * 0.58,
          115,
        );

        final double height = constraints.maxHeight;

        final Color accent = isBrake ? brakeRed : gasGreen;
        final String pedal = isBrake ? 'brake' : 'gas';

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            onChanged(
              pedal,
              details.localPosition.dy,
              height,
            );
          },
          onPanUpdate: (details) {
            onChanged(
              pedal,
              details.localPosition.dy,
              height,
            );
          },
          onPanEnd: (_) {
            onReleased(pedal);
          },
          onPanCancel: () {
            onReleased(pedal);
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(width / 2),
              border: Border.all(
                color: accent.withOpacity(0.40),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: Container(
                    width: 30,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white12,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        FractionallySizedBox(
                          heightFactor: value,
                          widthFactor: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(
                            0,
                            1 - (value * 2),
                          ),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
