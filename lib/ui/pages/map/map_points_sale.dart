import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/points_of_sale_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/points_of_sale_map.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/skeleton_sale.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/sale_buttons_container.dart';
import 'package:provider/provider.dart';

class MapPointsSale extends StatelessWidget {
  final String posLocationId;
  final String idCentro;
  final String posLocationName;
  final String posManager;
  final String posAddress;
  final String centro;
  final String posZoneDescription;
  final String locType;
  final String operador;
  final String posTown;
  final bool centrosComerciales;
  final String locDescription;

  const MapPointsSale({
    Key? key,
    required this.posLocationId,
    required this.idCentro,
    required this.posLocationName,
    required this.posManager,
    required this.posAddress,
    required this.centro,
    required this.posZoneDescription,
    required this.locType,
    required this.operador,
    required this.posTown,
    required this.centrosComerciales,
    required this.locDescription,
  }) : super(key: key);

  void reloadPage(BuildContext context) {
    context.read<PointsOfSaleProvider>().searchSales(
          posLocationId: posLocationId,
          posLocationName: posLocationName,
          posManager: posManager,
          posAddress: posAddress,
          centro: centro,
          locType: locType,
          operador: operador,
          posTown: posTown,
          centrosComerciales: centrosComerciales,
          locDescription: locDescription,
          posZoneDescription: posZoneDescription,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PointsOfSaleProvider()
        ..searchSales(
          posLocationId: posLocationId,
          posLocationName: posLocationName,
          posManager: posManager,
          posAddress: posAddress,
          centro: centro,
          locType: locType,
          operador: operador,
          posTown: posTown,
          centrosComerciales: centrosComerciales,
          locDescription: locDescription,
          posZoneDescription: posZoneDescription,
        ),
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<PointsOfSaleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingData) {
                  return const SkeletonSale();
                }

                if (provider.mapSales.isEmpty) {
                  return _buildNoSalesFound();
                }

                return const PointsOfSaleMap();
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
        floatingActionButton: SaleButtonsContainer(),
      ),
    );
  }

  Widget _buildNoSalesFound() {
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
              'No se encontraron puntos de venta para los filtros seleccionados.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros o utiliza otro ID.',
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
