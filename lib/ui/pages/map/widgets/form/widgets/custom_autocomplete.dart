import 'package:flutter/material.dart';

class CustomAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final List<String> options;
  final Function(String) onOptionSelected;
  final Function(String) onTextChanged;

  const CustomAutocomplete({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.options,
    required this.onOptionSelected,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Autocomplete<String>(
        optionsMaxHeight: 200.0,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          onTextChanged(textEditingValue.text);
          return options.where((String option) {
            return option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (String selectedOption) {
          controller.text = selectedOption;
          onOptionSelected(selectedOption);
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextField(
            controller: fieldTextEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
              suffixIcon: Icon(icon, color: const Color(0xFFb60000)),
              border: const OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            onChanged: onTextChanged,
          );
        },
      ),
    );
  }
}
