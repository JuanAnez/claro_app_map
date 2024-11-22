// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icc_maps/ui/pages/map/provider/actions/buttons_action_type.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/form/search_form_pos.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class SaleButtons {
  final Function(ButtonsActionType) _handleButtonAction;
  final bool _orientationVertical;
  final bool showSearchButton;

  SaleButtons(
    handleButtonAction,
    selectedButtons, {
    required orientationVertical,
    this.showSearchButton = true,
  })  : _handleButtonAction = handleButtonAction,
        _orientationVertical = orientationVertical;

  List<Widget> list(BuildContext context) {
    List<Widget> buttons = [];

    if (showSearchButton) {
      buttons.add(
        FloatingActionButton(
          splashColor: Colors.amber,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchFormPos()),
            );
          },
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(
            Icons.search,
            color: Colors.black87,
          ),
        ),
      );
      buttons.add(padding());
    }

    buttons.addAll([
      FloatingActionButton(
          splashColor: Colors.amber,
          onPressed: () => _handleButtonAction(ZoomMap(zoomIn: true)),
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(
            Icons.add,
            color: Colors.black87,
          )),
      padding(),
      FloatingActionButton(
          splashColor: Colors.amber,
          onPressed: () => _handleButtonAction(ZoomMap(zoomIn: false)),
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(
            Icons.remove,
            color: Colors.black87,
          )),
      padding(),
      FloatingActionButton(
          splashColor: Colors.amber,
          onPressed: () => _handleButtonAction(ChangeMapDisplay()),
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(
            Icons.map,
            color: Colors.black87,
          )),
      padding(),
      FloatingActionButton(
        splashColor: Colors.amber,
        onPressed: () async {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);

          LatLng userLocation = LatLng(position.latitude, position.longitude);

          context.read<PointsOfSaleProvider>().mapController.move(
                userLocation,
                14,
              );

          Marker userMarker = Marker(
            width: 80.0,
            height: 80.0,
            point: userLocation,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          );

          context.read<PointsOfSaleProvider>().addUserMarker(userMarker);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.my_location,
          color: Colors.white,
        ),
      ),
      padding(),
    ]);

    return buttons;
  }

  SizedBox padding() => SizedBox(
      width: _orientationVertical ? 1 : 10,
      height: _orientationVertical ? 10 : 1);
}
