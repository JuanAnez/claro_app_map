import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/menu_buttons_container.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/coverage_map.dart';
import 'package:icc_claro_app/features/features/providers/coverage_provider.dart';
import 'package:provider/provider.dart';

class MapCoverageScreen extends StatefulWidget {
  const MapCoverageScreen({super.key});

  @override
  State<MapCoverageScreen> createState() => _MapCoverageScreenState();
}

class _MapCoverageScreenState extends State<MapCoverageScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoverageProvider(),
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
              'Coberturas',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black87,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              const CoverageMap(),
            ],
          ),
          floatingActionButton: MenuButtonsContainer()),
    );
  }
}


              // Positioned(
              //   top: 40,
              //   left: 10,
              //   child: IconButton(
              //     icon: const Icon(Icons.arrow_back, size: 20),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //   ),
              // ),