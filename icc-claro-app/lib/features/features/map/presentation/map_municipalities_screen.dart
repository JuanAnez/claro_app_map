import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/floating_buttons.dart';
import 'package:icc_claro_app/core/widgets/search_form_pos.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/municipilaties_map.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:provider/provider.dart';

class MapMunicipalities extends StatefulWidget {
  final GetMarkersUseCase getMarkersUseCase;
  final MapsRepository mapsRepository;

  const MapMunicipalities({
    super.key,
    required this.getMarkersUseCase,
    required this.mapsRepository,
  });

  @override
  State<MapMunicipalities> createState() => _MapMunicipalitiesState();
}

class _MapMunicipalitiesState extends State<MapMunicipalities> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MapProvider(widget.getMarkersUseCase, widget.mapsRepository)..loadMunicipalities(context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
          ),
          title: const Text(
            'Participación de Mercado',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const MunicipalitiesMap(),
          ],
        ),
        floatingActionButton: Consumer<MapProvider>(
          builder: (context, provider, child) {
            return FloatingButtonsContainer(
              onZoomIn: provider.zoomIn,
              onZoomOut: provider.zoomOut,
              onLocate: provider.goToCurrentLocation,
              onToggleMapType: provider.toggleMapType,
              onSearch: () => _navigateTo(context, const SearchFormPos()),
              onToggleExpand: provider.toggleExpand,
              isExpanded: provider.isExpanded,
            );
          },
        ),
      ),
    );
  }
}

void _navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => page),
  );
}
