
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Widget page;
  final String text;

  const MyButton({
    super.key,
    required this.page,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Text(text),
    );
  }
}

