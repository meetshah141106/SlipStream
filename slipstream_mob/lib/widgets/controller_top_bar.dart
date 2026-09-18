import 'package:flutter/material.dart';

class ControllerTopBar extends StatelessWidget {
  final Set<String> pressedButtons;
  final VoidCallback onL1Down;
  final VoidCallback onL1Up;
  final VoidCallback onBackDown;
  final VoidCallback onBackUp;
  final VoidCallback onStartDown;
  final VoidCallback onStartUp;
  final VoidCallback onCalibrate;
  final VoidCallback onR1Down;
  final VoidCallback onR1Up;
  final Color surface;
  final Color blue;
  final Color cyan;

  const ControllerTopBar({
    super.key,
    required this.pressedButtons,
    required this.onL1Down,
    required this.onL1Up,
    required this.onBackDown,
    required this.onBackUp,
    required this.onStartDown,
    required this.onStartUp,
    required this.onCalibrate,
    required this.onR1Down,
    required this.onR1Up,
    required this.surface,
    required this.blue,
    required this.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        controllerTopButton(
          'L1',
          onL1Down,
          onL1Up,
        ),
        const SizedBox(width: 7),
        smallTopButton(
          Icons.arrow_back,
          'Back',
          onBackDown,
          onBackUp,
        ),
        const SizedBox(width: 7),
        smallTopButton(
          Icons.play_arrow,
          'Start',
          onStartDown,
          onStartUp,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onCalibrate,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: blue.withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.center_focus_strong,
                  color: cyan,
                  size: 15,
                ),
                const SizedBox(width: 6),
                const Text(
                  'CALIBRATE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        controllerTopButton(
          'R1',
          onR1Down,
          onR1Up,
        ),
      ],
    );
  }

  Widget controllerTopButton(
    String text,
    VoidCallback onDown,
    VoidCallback onUp,
  ) {
    final bool pressed = pressedButtons.contains(text);

    return SizedBox(
      width: 60,
      child: GestureDetector(
        onTapDown: (_) => onDown(),
        onTapUp: (_) => onUp(),
        onTapCancel: onUp,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          height: 40,
          decoration: BoxDecoration(
            color: pressed
                ? blue.withOpacity(0.28)
                : surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: pressed
                  ? blue
                  : Colors.white.withOpacity(0.12),
              width: pressed ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget smallTopButton(
    IconData icon,
    String label,
    VoidCallback onDown,
    VoidCallback onUp,
  ) {
    final String buttonName = label == 'Back' ? 'BACK' : 'START';
    final bool pressed = pressedButtons.contains(buttonName);

    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: SizedBox(
        width: 45,
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              width: 45,
              height: 32,
              decoration: BoxDecoration(
                color: pressed
                    ? blue.withOpacity(0.25)
                    : surface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: pressed
                      ? blue
                      : Colors.white.withOpacity(0.12),
                  width: pressed ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: pressed ? Colors.white : Colors.white60,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: 8,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
