// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:icc_maps/ui/pages/map/provider/google_map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/menu_google.dart';
import 'package:provider/provider.dart';


class MenuGoogleButtons extends StatelessWidget {
  MenuGoogleButtons({super.key});
  late GoogleMapProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = context.watch<GoogleMapProvider>();

    return OrientationBuilder(builder: (context, orientation) {
    if (orientation == Orientation.portrait)
      return verticalButtons(context);
    else
      return horizontalButtons(context);
  });
  }

  Column verticalButtons(BuildContext context) => Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (provider.isExpanded)
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: MenuGoogle(provider.handleButtonAction,
                    provider.selectedButtons,
                    orientationVertical: true, context: context)
                .list(),
          ),
        collapseButton(context),
      ],
    );

Row horizontalButtons(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (provider.isExpanded)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: MenuGoogle(provider.handleButtonAction,
                    provider.selectedButtons,
                    orientationVertical: false,
                    context: context
                    )
                .list(),
          ),
        collapseButton(context),
      ],
    );


  FloatingActionButton collapseButton(BuildContext context) => FloatingActionButton(
      onPressed: () => provider.handleButtonAction(
        CollapseButtons(),
        context,
      ),
      backgroundColor: Colors.white.withOpacity(0.6),
      child: Icon(provider.isExpanded ? Icons.close : Icons.add),
    );



}
