// ignore_for_file: curly_braces_in_flow_control_structures, must_be_immutable, unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/menu_buttons.dart';
import 'package:provider/provider.dart';

class MenuButtonsContainer extends StatelessWidget {
  MenuButtonsContainer({super.key});
  late MapProvider mapProvider;

  @override
  Widget build(BuildContext context) {
    mapProvider = context.watch<MapProvider>();

    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait)
        return verticalButtons();
      else
        return horizontalButtons();
    });
  }

  Column verticalButtons() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (mapProvider.isExpanded)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: MenuButtons(mapProvider.handleButtonAction,
                      mapProvider.selectedButtons,
                      orientationVertical: true)
                  .list(),
            ),
          collapseButton(),
        ],
      );

  Row horizontalButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (mapProvider.isExpanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: MenuButtons(mapProvider.handleButtonAction,
                      mapProvider.selectedButtons,
                      orientationVertical: false)
                  .list(),
            ),
          collapseButton(),
        ],
      );

  FloatingActionButton collapseButton() => FloatingActionButton(
        onPressed: () => mapProvider.handleButtonAction(CollapseButtons()),
        backgroundColor: Colors.white.withOpacity(0.6),
        child: Icon(mapProvider.isExpanded ? Icons.close : Icons.add),
      );
}
