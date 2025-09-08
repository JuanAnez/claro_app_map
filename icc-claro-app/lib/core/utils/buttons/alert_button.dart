import 'package:flutter/material.dart';

class AlertButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const AlertButton({
    required this.text,
    required this.onPressed,
    required this.color,
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(text),
    );
  }
}