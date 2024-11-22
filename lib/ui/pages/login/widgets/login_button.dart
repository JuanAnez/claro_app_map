import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final Function() onPressed;

  const LoginButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            minimumSize: const Size(335.0, 62.0),
            backgroundColor: const Color(0xFFb60000)),
        child: const Text(
          'Ingresar',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
        ));
  }
}
