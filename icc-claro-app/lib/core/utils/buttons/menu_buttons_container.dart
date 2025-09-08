// ignore_for_file: curly_braces_in_flow_control_structures, must_be_immutable, unnecessary_import

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/actions/buttons_action_type.dart';
import 'package:icc_claro_app/core/utils/buttons/menu_buttons.dart';
import 'package:icc_claro_app/features/features/providers/coverage_provider.dart';
import 'package:provider/provider.dart';

class MenuButtonsContainer extends StatelessWidget {
  MenuButtonsContainer({super.key});
  late CoverageProvider coverageProvider;

  
  @override
  Widget build(BuildContext context) {
    coverageProvider = context.watch<CoverageProvider>();

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
        if (coverageProvider.isExpanded)
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: MenuButtons(coverageProvider.handleButtonAction,
                    coverageProvider.selectedButtons,
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
        if (coverageProvider.isExpanded)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: MenuButtons(coverageProvider.handleButtonAction,
                    coverageProvider.selectedButtons,
                    orientationVertical: false,
                    context: context
                    )
                .list(),
          ),
        collapseButton(context),
      ],
    );


  FloatingActionButton collapseButton(BuildContext context) => FloatingActionButton(
      onPressed: () => coverageProvider.handleButtonAction(
        CollapseButtons(),
        context,
      ),
      backgroundColor: Colors.white.withOpacity(0.6),
      child: Icon(coverageProvider.isExpanded ? Icons.close : Icons.add),
    );



}
