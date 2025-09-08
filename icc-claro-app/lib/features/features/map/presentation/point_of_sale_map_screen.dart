// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icc_claro_app/core/utils/buttons/floating_buttons.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/core/widgets/search_form_pos.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/filter_drawer.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:icc_claro_app/features/features/providers/point_of_sale_providers.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_detail_create_screen.dart';
import 'package:icc_claro_app/core/utils/helpers/get_roles.dart';
import 'package:provider/provider.dart';

class PointOfSaleMapScreen extends StatefulWidget {
  const PointOfSaleMapScreen({super.key});

  @override
  State<PointOfSaleMapScreen> createState() => _PointOfSaleMapScreenState();
}

class _PointOfSaleMapScreenState extends State<PointOfSaleMapScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PointOfSaleProvider>();
    final user = context.watch<UserProvider>().getUser();
    
    final roles = getRolesFromAuthorities(user?.authorities);
    
    // Debug temporal para verificar que funciona
    print("🔍 PointOfSaleMapScreen - Roles: $roles, ¿Contiene POS_USER?: ${roles.contains('POS_USER')}");
    

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
            // context.read<PointOfSaleProvider>().clearMarkersCache();
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
        ),
      ),
      endDrawer: FilterDrawer(),
      body: const _AllMarkersMapWrapper(),
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
        isExpanded: provider.isExpanded,
        createPos: (roles.contains('POS_USER'))
            ? () {
                print("🔍 createPos button clicked!");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RouteDetailCreateScreen()));
              }
            : null,
      ),
    );
  }
}

class _AllMarkersMapWrapper extends StatefulWidget {
  const _AllMarkersMapWrapper();

  @override
  State<_AllMarkersMapWrapper> createState() => _AllMarkersMapWrapperState();
}

class _AllMarkersMapWrapperState extends State<_AllMarkersMapWrapper> {
  Set<Marker>? _markers;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMarkers();
    });
  }

  Future<void> _loadMarkers() async {
    final provider = context.read<PointOfSaleProvider>();

    if (provider.markers.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _markers = provider.markers;
          _loading = false;
        });
      }
      return;
    }

    await provider.loadMarkers(context);
    if (mounted) {
      setState(() {
        _markers = provider.markers;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PointOfSaleProvider>();

    if (_loading || _markers == null) {
      return const Center(child: LoadingProgress());
    }

    return GoogleMap(
      onMapCreated: (controller) {
        provider.setMapController(controller);
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
