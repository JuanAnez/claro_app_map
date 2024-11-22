import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/municipalities_map.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/sale_buttons_container.dart';
import 'package:provider/provider.dart';

class MapMunicipalities extends StatelessWidget {
  const MapMunicipalities({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PointsOfSaleProvider()..loadMunicipalities(),
      child: Scaffold(
        body: Stack(
          children: [
            const MunicipalitiesMap(),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.blueGrey[900], size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Consumer<PointsOfSaleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black12,
                      color: Colors.black26,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: SaleButtonsContainer(showSearchButton: false),
      ),
    );
  }
}
