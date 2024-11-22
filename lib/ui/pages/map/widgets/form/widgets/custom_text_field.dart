import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;
  final TextInputType inputType;
  final bool readOnly;
  final TextInputAction inputAction;
  final bool enableInteractiveSelection;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.icon = Icons.text_fields,
    this.isNumber = false,
    this.inputType = TextInputType.text,
    this.readOnly = false,
    this.inputAction = TextInputAction.next,
    this.enableInteractiveSelection = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType:
            isNumber ? const TextInputType.numberWithOptions() : inputType,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        readOnly: readOnly,
        textInputAction: inputAction,
        enableInteractiveSelection: enableInteractiveSelection,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          suffixIcon: Icon(icon, color: const Color(0xFFb60000)),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
