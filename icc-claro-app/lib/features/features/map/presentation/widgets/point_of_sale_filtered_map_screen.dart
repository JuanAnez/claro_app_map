import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/buttons/floating_buttons.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/core/widgets/search_form_pos.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/filter_drawer.dart';
import 'package:icc_claro_app/features/features/providers/point_of_sale_providers.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_detail_create_screen.dart';
import 'package:icc_claro_app/core/utils/helpers/get_roles.dart';
import 'package:provider/provider.dart';

class PointOfSaleFilteredMapScreen extends StatelessWidget {
  final Map<String, String> filters;

  const PointOfSaleFilteredMapScreen({
    super.key,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().getUser();
    final roles = getRolesFromAuthorities(user?.authorities);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Puntos de Venta',
              style: TextStyle(fontSize: 20, color: Colors.white)),
          backgroundColor: Colors.black,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
          )),
      endDrawer: FilterDrawer(),
      body: _FilteredMapWrapper(filters: filters),
      floatingActionButton: FloatingButtonsContainer(
        onZoomIn: () => context.read<PointOfSaleProvider>().zoomIn(),
        onZoomOut: () => context.read<PointOfSaleProvider>().zoomOut(),
        onLocate: () =>
            context.read<PointOfSaleProvider>().goToCurrentLocation(),
        onToggleMapType: () =>
            context.read<PointOfSaleProvider>().toggleMapType(),
        onSearch: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SearchFormPos())),
        onToggleExpand: () =>
            context.read<PointOfSaleProvider>().toggleExpand(),
        isExpanded: context.watch<PointOfSaleProvider>().isExpanded,
        createPos: (roles.contains('POS_USER'))
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RouteDetailCreateScreen()))
            : null,
      ),
    );
  }
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
            size: 60,
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

class _FilteredMapWrapper extends StatefulWidget {
  final Map<String, String> filters;

  const _FilteredMapWrapper({required this.filters});

  @override
  State<_FilteredMapWrapper> createState() => _FilteredMapWrapperState();
}

class _FilteredMapWrapperState extends State<_FilteredMapWrapper> {
  Set<Marker>? _markers;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final provider = context.read<PointOfSaleProvider>();
    if (provider.cache.isEmpty) {
      final locations = await provider.repository.fetchLocations(context: context);
      for (final loc in locations) {
        final id = loc['posLocationId'].toString();
        provider.cache.putIfAbsent(id, () => loc);
      }
    }

    final all = provider.cache.values;
    const exactMatchKeys = {'posLocationId', 'idCentro'};

    final filtered = all.where((location) {
      return widget.filters.entries.every((entry) {
        final key = entry.key;
        final search = entry.value.toLowerCase().trim();
        if (search.isEmpty) return true;

        final locValue = switch (key) {
              'posTypeId' => location['locTypeId'],
              'posOperatorId' => location['posOperatorId'],
              _ => location[key],
            }
                ?.toString()
                .toLowerCase()
                .trim() ??
            '';

        if (search.contains(',')) {
          final values = search.split(',').map((s) => s.trim());
          return values.contains(locValue);
        }

        return exactMatchKeys.contains(key)
            ? locValue == search
            : locValue.contains(search);
      });
    }).toList();

    final markers = await provider.createMarkers(context, filtered);
    print('Ejemplo de location: ${provider.cache.values.first}');

    if (mounted) {
      setState(() => _markers = markers);

      if (markers.length == 1) {
        final marker = markers.first;
        await Future.delayed(Duration(milliseconds: 300));
        provider.mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(marker.position, 11),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PointOfSaleProvider>();

    if (_markers == null) {
      return const Center(child: LoadingProgress());
    }

    if (_markers!.isEmpty) {
      return _buildNoSalesFound();
    }

    return GoogleMap(
      onMapCreated: (controller) {
        context.read<PointOfSaleProvider>().setMapController(controller);
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(18.238384, -66.475422),
        zoom: 9.5,
      ),
      mapType: provider.mapType,
      markers: _markers!,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onCameraMove: (CameraPosition position) {
        provider.checkBounds(position.target);
      },
    );
  }
}
