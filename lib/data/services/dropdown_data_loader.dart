// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:icc_maps/data/network/payload/MessageResponse.dart';
import 'package:icc_maps/data/network/webtest/mocktest_repository.dart';

class DropdownDataLoader with ChangeNotifier {
  List<String> posDescriptions = [];
  List<Map<String, dynamic>> posTypes = [];
  List<Map<String, dynamic>> operadores = [];
  List<Map<String, dynamic>> posChannel = [];
  List<Map<String, dynamic>> posTowns = [];
  List<Map<String, dynamic>> allTowns = [];
  List<Map<String, dynamic>> allLocations = [];

  List<Map<String, dynamic>> filteredLocations = [];
  List<int> selectedPosLocations = [];

  List<String> posZones = [];

  bool isLoading = false;
  String errorMessage = '';

  String? selectedPosTown;
  String? selectedPosLocation;

  void clearAllTownsAndLocations() {
    allTowns.clear();
    allLocations.clear();
    selectedPosLocations.clear();
    notifyListeners();
  }

  Future<void> loadDropdownData() async {
    try {
      isLoading = true;
      notifyListeners();

      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getPosLocDropdownInputs();

      if (response.ok) {
        final jsonData = response.content as Map<String, dynamic>;

        posDescriptions = (jsonData['allPosDesc'] as List)
            .map<String>((item) => item['lovDescription'] as String)
            .toList();

        operadores = (jsonData['allPosOperators'] as List)
            .map<Map<String, dynamic>>((item) {
          return {
            'lovId': item['lovId'],
            'lovDescription': item['lovDescription'],
          };
        }).toList();

        posTypes =
            (jsonData['allPosTypes'] as List).map<Map<String, dynamic>>((item) {
          return {
            'lovId': item['lovId'],
            'lovDescription': item['lovDescription'],
          };
        }).toList();

        posChannel = (jsonData['allPosChannels'] as List)
            .map<Map<String, dynamic>>((item) {
          return {
            'lovId': item['lovId'],
            'lovDescription': item['lovDescription'],
          };
        }).toList();
        posTowns =
            (jsonData['allPosTowns'] as List).map<Map<String, dynamic>>((item) {
          return {
            'zone': item['zone'],
            'zoneDesc': item['zoneDesc'],
            'zoneTown': item['zoneTown'],
          };
        }).toList();
      } else {
        errorMessage = 'Error loading dropdown data: ${response.message}';
      }
    } catch (e) {
      errorMessage = 'Exception loading dropdown data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllTowns() async {
    try {
      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getTowns();

      if (response.ok) {
        final jsonData = response.content as List<dynamic>;
        allTowns = jsonData.map<Map<String, dynamic>>((item) {
          return {
            'townName': item['townName'],
            'townId': item['townId'],
          };
        }).toList();
      } else {
        errorMessage = 'Error fetching towns: ${response.message}';
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Exception fetching towns: $e';
      notifyListeners();
    }
  }

  Future<void> fetchAllLocations(String selectedTown) async {
    try {
      isLoading = true;
      notifyListeners();

      MocktestClient client = MocktestClient();
      MessageResponse response = await client.getAllLocations(selectedTown);

      if (response.ok) {
        final jsonData = response.content as List<dynamic>;
        filteredLocations = jsonData.map<Map<String, dynamic>>((item) {
          return {
            'posLocationId': item['posLocationId'],
            'posLocationName': item['posLocationName'],
          };
        }).toList();
      } else {
        errorMessage = 'Error fetching locations: ${response.message}';
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Exception fetching locations: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedLocations(List<int> selectedIds) {
    selectedPosLocations = selectedIds;
    notifyListeners();
  }

  void toggleLocationSelection(int locationId) {
    if (selectedPosLocations.contains(locationId)) {
      selectedPosLocations.remove(locationId);
    } else {
      selectedPosLocations.add(locationId);
    }
    notifyListeners();
  }
}
