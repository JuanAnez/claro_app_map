// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_import, unused_import, non_constant_identifier_names, use_build_context_synchronously, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/custom_map.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/menu_buttons_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider()..loadAllGeoJson(),
      builder: (_, __) => Scaffold(
        body: Stack(
          children: [
            CustomMap(),
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
        floatingActionButton: MenuButtonsContainer(),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/map/provider/map_provider.dart';
import 'package:icc_maps/ui/pages/map/widgets/map/custom_map.dart';
import 'package:icc_maps/ui/pages/map/widgets/menu_buttons/menu_buttons_container.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider()..loadAllGeoJson(),
      builder: (_, __) => Scaffold(
        body: Stack(
          children: [
            const CustomMap(),
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
        floatingActionButton: MenuButtonsContainer(),
      ),
    );
  }
}
*/