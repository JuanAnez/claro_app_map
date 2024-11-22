// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icc_maps/domain/types/antennas_types.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';

class MenuButtons {
  final Function(ButtonsActionType) _handleButtonAction;
  final Set<Enum> _selectedButtons;
  final bool _orientationVertical;

  MenuButtons(handleButtonAction, selectedButtons,
      {required orientationVertical})
      : _handleButtonAction = handleButtonAction,
        _selectedButtons = selectedButtons,
        _orientationVertical = orientationVertical;

  List<Widget> list() => [
        _antennaButton(AntennasTypes.fwa),
        padding(),
        _antennaButton(AntennasTypes.t5g),
        padding(),
        _coverageButton(CoveragesTypes.gpn),
        padding(),
        _coverageButton(CoveragesTypes.fiveM),
        padding(),
        _coverageButton(CoveragesTypes.tenM),
        padding(),
        _coverageButton(CoveragesTypes.lte),
        padding(),
        _coverageButton(CoveragesTypes.threeG),
        padding(),
        FloatingActionButton(
            onPressed: () => _handleButtonAction(ZoomMap(zoomIn: true)),
            backgroundColor: Colors.white.withOpacity(0.6),
            child: const Icon(
              Icons.add,
              color: Colors.black87,
            )),
        padding(),
        FloatingActionButton(
            onPressed: () => _handleButtonAction(ZoomMap(zoomIn: false)),
            backgroundColor: Colors.white.withOpacity(0.6),
            child: const Icon(
              Icons.remove,
              color: Colors.black87,
            )),
        padding(),
        FloatingActionButton(
            onPressed: () => _handleButtonAction(ChangeMapDisplay()),
            backgroundColor: Colors.white.withOpacity(0.6),
            child: const Icon(
              Icons.map,
              color: Colors.black87,
            )),
        padding()
      ];

  Color _bgColor(Enum buttonType) {
    if (_selectedButtons.contains(buttonType)) {
      return Colors.green.withOpacity(0.6);
    }
    return Colors.white.withOpacity(0.6);
  }

  StatelessWidget _antennaButton(AntennasTypes type) {
    Color iconColor = type == AntennasTypes.fwa ? Colors.red : Colors.amber;

    if (_orientationVertical)
      return FABWithText(
        label: type.key,
        iconColor: iconColor,
        icon: Icons.cell_tower_outlined,
        backgroundColor: _bgColor(type),
        onPressed: () => _handleButtonAction(ShowAntennas(type)),
      );
    else
      return FABHorizontal(
        label: type.key,
        iconColor: iconColor,
        icon: Icons.cell_tower_outlined,
        backgroundColor: _bgColor(type),
        onPressed: () => _handleButtonAction(ShowAntennas(type)),
      );
  }

  FloatingActionButton _coverageButton(CoveragesTypes type) =>
      FloatingActionButton(
        onPressed: () => _handleButtonAction(ShowCoverages(type)),
        backgroundColor: _bgColor(type),
        child: Text(type.key,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
      );

  SizedBox padding() => SizedBox(
      width: _orientationVertical ? 1 : 10,
      height: _orientationVertical ? 10 : 1);
}

class FABWithText extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const FABWithText({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class FABHorizontal extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const FABHorizontal({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color.fromARGB(255, 184, 141, 141),
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 3),
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
