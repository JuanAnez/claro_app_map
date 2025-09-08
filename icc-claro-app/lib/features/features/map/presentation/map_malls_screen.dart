import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/core/widgets/search_form_pos.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/core/utils/buttons/floating_buttons.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/malls_map.dart';
import 'package:icc_claro_app/features/features/providers/map_provider.dart';
import 'package:provider/provider.dart';

class MapMallsScreen extends StatefulWidget {
  final GetMarkersUseCase getMarkersUseCase;
  final MapsRepository mapsRepository;
  final int? groupId;

  const MapMallsScreen({
    super.key,
    this.groupId,
    required this.getMarkersUseCase,
    required this.mapsRepository,
  });

  @override
  State<MapMallsScreen> createState() => _MapMallsScreenState();
}

class _MapMallsScreenState extends State<MapMallsScreen> {
  late final MapProvider mapProvider;

  @override
  void initState() {
    super.initState();
    mapProvider = MapProvider(widget.getMarkersUseCase, widget.mapsRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapProvider.loadMalls(context, widget.groupId);
    });
  }

  @override
  void dispose() {
    mapProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapProvider>.value(
      value: mapProvider,
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
            'Centros Comerciales',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Consumer<MapProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingData) {
                  return const LoadingProgress();
                }
                if (provider.mapMalls['malls']?.isEmpty ?? true) {
                  return _beautyCenter();
                }
                return const MallsMap();
              },
            ),
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

  Widget _beautyCenter() {
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

void _navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => page),
  );
}



            // Positioned(
            //   top: 40,
            //   left: 10,
            //   child: IconButton(
            //     icon: Icon(Icons.arrow_back,
            //         color: Colors.blueGrey[900], size: 20),
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //   ),
            // ),
