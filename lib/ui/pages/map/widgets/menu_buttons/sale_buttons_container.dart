// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/sale_buttons.dart';
import 'package:provider/provider.dart';

class SaleButtonsContainer extends StatelessWidget {
  final bool showSearchButton;

  SaleButtonsContainer({super.key, this.showSearchButton = true});

  late PointsOfSaleProvider pointsOfSaleProvider;

  @override
  Widget build(BuildContext context) {
    pointsOfSaleProvider = context.watch<PointsOfSaleProvider>();

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
          if (pointsOfSaleProvider.isExpanded)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: SaleButtons(
                pointsOfSaleProvider.handleButtonAction,
                pointsOfSaleProvider.selectedButtons,
                orientationVertical: true,
                showSearchButton: showSearchButton,
              ).list(context),
            ),
          collapseButton(),
        ],
      );

  Row horizontalButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (pointsOfSaleProvider.isExpanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: SaleButtons(
                pointsOfSaleProvider.handleButtonAction,
                pointsOfSaleProvider.selectedButtons,
                orientationVertical: false,
                showSearchButton: showSearchButton,
              ).list(context),
            ),
          collapseButton(),
        ],
      );

  FloatingActionButton collapseButton() => FloatingActionButton(
        onPressed: () =>
            pointsOfSaleProvider.handleButtonAction(CollapseButtons()),
        backgroundColor: Colors.white.withOpacity(0.6),
        child: Icon(pointsOfSaleProvider.isExpanded ? Icons.close : Icons.add),
      );
}
