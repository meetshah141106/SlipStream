import 'package:flutter/material.dart';

class ConnectionIndicator extends StatelessWidget {
  final Color surface;
  final Color gasGreen;

  const ConnectionIndicator({
    super.key,
    required this.surface,
    required this.gasGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      bottom: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: gasGreen.withOpacity(0.20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: gasGreen,
              size: 6,
            ),
            const SizedBox(width: 5),
            const Text(
              'CONNECTED',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
