import 'package:flutter/material.dart';

class FloatingButtonsContainer extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocate;
  final VoidCallback onToggleMapType;
  final VoidCallback onSearch;
  final VoidCallback onToggleExpand;
  final VoidCallback? createPos;
  final bool isExpanded;

  const FloatingButtonsContainer({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocate,
    required this.onToggleMapType,
    required this.onSearch,
    required this.onToggleExpand,
    this.createPos,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? _verticalButtons(context)
            : _horizontalButtons(context);
      },
    );
  }

  Widget _verticalButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isExpanded)
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildExpandedButtons(isVertical: true, context: context),
          ),
        _expandCollapseButton(),
      ],
    );
  }

  Widget _horizontalButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isExpanded)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:
                _buildExpandedButtons(isVertical: false, context: context),
          ),
        _expandCollapseButton(),
      ],
    );
  }

  List<Widget> _buildExpandedButtons({
    required bool isVertical,
    required BuildContext context,
  }) {
    final spacing =
        SizedBox(width: isVertical ? 0 : 10, height: isVertical ? 10 : 0);
    final buttons = [
      _customFloatingButton(onZoomIn, Icons.add, "btn_zoom_in"),
      spacing,
      _customFloatingButton(onZoomOut, Icons.remove, "btn_zoom_out"),
      spacing,
      _customFloatingButton(onLocate, Icons.my_location, "btn_location"),
      spacing,
      _customFloatingButton(onToggleMapType, Icons.map, "btn_map_type"),
      spacing,
      _customFloatingButton(onSearch, Icons.search, "btn_search"),
      spacing,
    ];

    if (createPos != null) {
      buttons.add(
          _customFloatingButton(createPos!, Icons.store, "btn_create_pos"));
      buttons.add(spacing);
    }

    return buttons;
  }

  Widget _expandCollapseButton() {
    return _customFloatingButton(
      onToggleExpand,
      isExpanded ? Icons.close : Icons.add,
      "btn_expand",
    );
  }

  Widget _customFloatingButton(
      VoidCallback onPressed, IconData icon, String heroTag) {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: Colors.white.withOpacity(0.6),
        foregroundColor: Colors.black,
        child: Icon(icon, size: 24),
      ),
    );
  }
}
