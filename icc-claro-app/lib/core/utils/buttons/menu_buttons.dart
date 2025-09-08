// ignore_for_file: unnecessary_import, deprecated_member_use, unreachable_switch_default, unused_field

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/actions/buttons_action_type.dart';
import 'package:icc_claro_app/core/types/antennas_types.dart';
import 'package:icc_claro_app/core/types/coverages_types.dart';
import 'package:icc_claro_app/features/features/providers/coverage_provider.dart';
import 'package:provider/provider.dart';

class MenuButtons {
  final Function(ButtonsActionType, BuildContext) _handleButtonAction;
  final Set<Enum> _selectedButtons;
  final bool _orientationVertical;
  final BuildContext context;

  MenuButtons(
    this._handleButtonAction,
    this._selectedButtons, {
    required this.context,
    required orientationVertical,
  }) : _orientationVertical = orientationVertical;

  List<Widget> list() => [
        _antennaButton(AntennasTypes.fwa),
        padding(),
        _antennaButton(AntennasTypes.t5g),
        padding(),
        _coverageButton(CoveragesTypes.gpn),
        padding(),
        _coverageButton(CoveragesTypes.fiveM),
        padding(),
        // _coverageButton(CoveragesTypes.tenM),
        // padding(),
        _coverageButton(CoveragesTypes.lte),
        padding(),
        _coverageButton(CoveragesTypes.threeG),
        padding(),
        FloatingActionButton(
          onPressed: () => _handleButtonAction(ZoomMap(zoomIn: true), context),
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(Icons.add, color: Colors.black87),
        ),
        padding(),
        FloatingActionButton(
          onPressed: () => _handleButtonAction(ZoomMap(zoomIn: false), context),
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(Icons.remove, color: Colors.black87),
        ),
        padding(),
        FloatingActionButton(
          onPressed: () => _handleButtonAction(ChangeMapDisplay(), context),
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(Icons.map, color: Colors.black87),
        ),
        padding(),
      ];

  FloatingActionButton _antennaButton(AntennasTypes type) {
    final coverageProvider = context.read<CoverageProvider>();
    final bool isSelected = coverageProvider.selectedAntennas.contains(type);
    Color buttonColor;
    Color textColor;

    switch (type) {
      case AntennasTypes.fwa:
        buttonColor = Colors.red.withOpacity(0.7);
        textColor = Colors.white;
        break;
      case AntennasTypes.t5g:
        buttonColor = Colors.amber.withOpacity(0.7);
        textColor = Colors.white;
        break;
      default:
        buttonColor = isSelected
            ? Colors.green.withOpacity(0.6)
            : Colors.white.withOpacity(0.6);
        textColor = Colors.black87;
    }

    return FloatingActionButton(
      onPressed: () {
        coverageProvider.toggleAntennaVisibility(type, context);
      },
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      child: Text(
        type.key,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  FloatingActionButton _coverageButton(CoveragesTypes type) {
    final coverageProvider = context.read<CoverageProvider>();
    final bool isSelectedCoverage =
        coverageProvider.selectedButtons.contains(type);
    Color buttonColor;
    Color textColor;

    switch (type) {
      case CoveragesTypes.gpn:
        buttonColor = const Color(0xFFFF00FF).withOpacity(0.7);
        textColor = Colors.white;
        break;
      case CoveragesTypes.fiveM:
        buttonColor = const Color(0x5605b5).withOpacity(0.7);
        textColor = Colors.white;
        break;
      case CoveragesTypes.tenM:
        buttonColor = const Color(0x00ffff).withOpacity(0.7);
        textColor = Colors.white;
        break;
      case CoveragesTypes.lte:
        buttonColor = const Color(0x0dff00).withOpacity(0.7);
        textColor = Colors.white;
        break;
      case CoveragesTypes.threeG:
        buttonColor = const Color(0x88d750).withOpacity(0.7);
        textColor = Colors.white;
        break;
      default:
        buttonColor = isSelectedCoverage
            ? Colors.green.withOpacity(0.6)
            : Colors.white.withOpacity(0.6);
        textColor = Colors.black87;
    }

    return FloatingActionButton(
      onPressed: () async {
        await _handleButtonAction(ShowCoverages(type), context);
      },
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      child: Text(
        type.key,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
