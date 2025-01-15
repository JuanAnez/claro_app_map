import 'package:flutter/material.dart';
import 'package:icc_maps/domain/types/antennas_types.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/menu_buttons.dart';

class MenuGoogle {
  final Function(ButtonsActionType, BuildContext) _handleButtonAction;
  final Set<Enum> _selectedButtons;
  final bool _orientationVertical;
  final BuildContext context;

  MenuGoogle(
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
        _coverageButton(CoveragesTypes.tenM),
        padding(),
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

  Color _bgColor(Enum buttonType) {
    if (_selectedButtons.contains(buttonType)) {
      return Colors.green.withOpacity(0.6);
    }
    return Colors.white.withOpacity(0.6);
  }

  StatelessWidget _antennaButton(AntennasTypes type) {
    Color iconColor = type == AntennasTypes.fwa ? Colors.red : Colors.amber;

    if (_orientationVertical) {
      return FABWithText(
        label: type.key,
        iconColor: iconColor,
        icon: Icons.cell_tower_outlined,
        backgroundColor: _bgColor(type),
        onPressed: () => _handleButtonAction(ShowAntennas(type), context),
      );
    } else {
      return FABHorizontal(
        label: type.key,
        iconColor: iconColor,
        icon: Icons.cell_tower_outlined,
        backgroundColor: _bgColor(type),
        onPressed: () => _handleButtonAction(ShowAntennas(type), context),
      );
    }
  }

 FloatingActionButton _coverageButton(CoveragesTypes type) {
  return FloatingActionButton(
    onPressed: () => _handleButtonAction(
      ShowCoverages(type),
      context,
    ),
    backgroundColor: _bgColor(type),
    child: Text(
      type.key,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    ),
  );
}




  SizedBox padding() => SizedBox(
      width: _orientationVertical ? 1 : 10,
      height: _orientationVertical ? 10 : 1);
}
