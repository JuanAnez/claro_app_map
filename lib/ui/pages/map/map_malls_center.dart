import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/malls_center_map.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/skeleton_map.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/sale_buttons_container.dart';
import 'package:provider/provider.dart';

class MapMallsCenter extends StatelessWidget {
  final int? groupId;

  const MapMallsCenter({
    super.key,
    this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = PointsOfSaleProvider();
        provider.loadMalls(groupId);
        return provider;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<PointsOfSaleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingData) {
                  return const SkeletonMap();
                }

                if (provider.mapMalls.isEmpty) {
                  return _beutyCenter();
                }

                return const MallsCenterMap();
              },
            ),
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
          ],
        ),
        floatingActionButton: SaleButtonsContainer(showSearchButton: false),
      ),
    );
  }

  Widget _beutyCenter() {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron centros comerciales para este ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Inténtalo con otro ID.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
