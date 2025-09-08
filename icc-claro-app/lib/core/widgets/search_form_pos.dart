// ignore_for_file: library_private_types_in_public_api, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/constants/towns_list.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/features/features/map/presentation/map_malls_screen.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/point_of_sale_filtered_map_screen.dart';

class SearchFormPos extends StatefulWidget {
  const SearchFormPos({super.key});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchFormPos> {
  final TextEditingController idPosController = TextEditingController();
  final TextEditingController idCentroController = TextEditingController();
  final TextEditingController nombrePosController = TextEditingController();
  final TextEditingController nombreMallController = TextEditingController();
  final TextEditingController nombreGerenteController = TextEditingController();
  final TextEditingController direccionPosController = TextEditingController();
  final TextEditingController centroController = TextEditingController();
  final TextEditingController tipoLocalidadController = TextEditingController();
  final TextEditingController tipoUbicacionController = TextEditingController();
  final TextEditingController operadorController = TextEditingController();
  final TextEditingController puebloController = TextEditingController();
  final TextEditingController descripcionUbicacionController =
      TextEditingController();

  bool centrosComerciales = false;

  String? selectedLocalZone;
  String? selectedLocationType;
  String? selectedOperador;
  String? selectedTown;
  String? selectedDescriptionLocation;

  List<String> locationTypes = [];
  List<String> operadores = [];
  List<String> locationDescription = [];
  List<String> localZone = [];
  List<Map<String, dynamic>> allMalls = [];
  List<String> mallNames = [];

  @override
  void initState() {
    super.initState();
    _loadLocationTypes();
    _loadOperadores();
    _loadLocation();
    _loadLocalZone();
    _loadAllMalls();
  }

  Future<void> _loadAllMalls() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.findMalls(context);

      if (response.ok) {
        setState(() {
          allMalls = response.additionalContent.cast<Map<String, dynamic>>();
          mallNames = allMalls
              .map((mall) => mall['group_NAME'] as String)
              .toSet()
              .toList()
            ..sort();
        });
      } else {
        print('Error loading malls: ${response.message}');
      }
    } catch (e) {
      print('Exception loading malls: $e');
    }
  }

  Future<void> _loadLocationTypes() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_TYPE');
      if (response.ok) {
        setState(() {
          locationTypes = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading location types: ${response.message}');
      }
    } catch (e) {
      print('Exception loading location types: $e');
    }
  }

  Future<void> _loadOperadores() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_OPERATOR');
      if (response.ok) {
        setState(() {
          operadores = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading operadores: ${response.message}');
      }
    } catch (e) {
      print('Exception loading operadores: $e');
    }
  }

  Future<void> _loadLocation() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response =
          await client.getPosLovByType('LOC_DESCRIPTION');
      if (response.ok) {
        setState(() {
          locationDescription = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading operadores: ${response.message}');
      }
    } catch (e) {
      print('Exception loading operadores: $e');
    }
  }

  Future<void> _loadLocalZone() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_ZONE');
      if (response.ok) {
        setState(() {
          localZone = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading operadores: ${response.message}');
      }
    } catch (e) {
      print('Exception loading operadores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Buscar Puntos de Venta',
          style: TextStyle(color: Colors.white),
        ),
        // Image.asset(
        //   'assets/images/icc_claro_appbar.png',
        //   height: 30,
        // ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey.shade500),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(context, 'Id del Punto de Venta',
                            Icons.search, idPosController),
                        _buildTextField(context, 'Id del Centro Comercial',
                            Icons.search, idCentroController),
                        _buildTextField(context, 'Nombre del Punto de Venta',
                            Icons.search, nombrePosController),
                        _buildTextField(context, 'Nombre del Centro Comercial',
                            Icons.search, nombreMallController),
                        _buildTextField(context, 'Nombre del Gerente',
                            Icons.person, nombreGerenteController),
                        _buildTextField(context, 'Dirección del Punto de Venta',
                            Icons.home, direccionPosController),
                        _buildDropdown(
                          label: 'Zona de Localidad',
                          value: selectedLocalZone,
                          items: localZone,
                          onChanged: (value) {
                            setState(() {
                              selectedLocalZone = value;
                              tipoLocalidadController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Tipo de Ubicación',
                          value: selectedLocationType,
                          items: locationTypes,
                          onChanged: (value) {
                            setState(() {
                              selectedLocationType = value;
                              tipoUbicacionController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Operador',
                          value: selectedOperador,
                          items: operadores,
                          onChanged: (value) {
                            setState(() {
                              selectedOperador = value;
                              operadorController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Pueblo',
                          value: selectedTown,
                          items: townsList,
                          onChanged: (value) {
                            setState(() {
                              selectedTown = value;
                              puebloController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Descripción de Ubicación',
                          value: selectedDescriptionLocation,
                          items: locationDescription,
                          onChanged: (value) {
                            setState(() {
                              selectedDescriptionLocation = value;
                              descripcionUbicacionController.text = value!;
                            });
                          },
                        ),
                        _buildLatLonFields(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _onSearchPressed,
              elevation: 4,
              backgroundColor: const Color(0xFFb60000).withOpacity(0.7),
              foregroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatLonFields(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Lat',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Lon',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSearchPressed() async {
    final mapsRepository = MapsRepository();
    final getMarkersUseCase = GetMarkersUseCase(mapsRepository);

    if (idCentroController.text.isNotEmpty) {
      final groupId = int.tryParse(idCentroController.text);
      if (groupId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapMallsScreen(
              key: Key(idCentroController.text),
              groupId: groupId,
              getMarkersUseCase: getMarkersUseCase,
              mapsRepository: mapsRepository,
            ),
          ),
        );
        return;
      } else {
        print("Error: Invalid groupId");
        return;
      }
    }

    if (nombreMallController.text.isNotEmpty) {
      try {
        final matchingMall = allMalls.firstWhere(
          (mall) => mall['group_NAME']
              .toString()
              .toLowerCase()
              .contains(nombreMallController.text.toLowerCase()),
          orElse: () => {},
        );

        if (matchingMall != null) {
          final groupId = matchingMall['group_ID'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapMallsScreen(
                key: Key(groupId.toString()),
                groupId: groupId,
                getMarkersUseCase: getMarkersUseCase,
                mapsRepository: mapsRepository,
              ),
            ),
          );
          return;
        } else {
          print("❌ No se encontró ningún centro comercial con ese nombre.");
        }
      } catch (e) {
        print("❌ Excepción al buscar por nombre: $e");
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointOfSaleFilteredMapScreen(
          key: Key(idPosController.text),
          filters: {
            'posLocationId': idPosController.text,
            'posGroupName': idCentroController.text,
            'posLocationName': nombrePosController.text,
            'manager': nombreGerenteController.text,
            'posAddress': direccionPosController.text,
            'centro': centroController.text,
            'posZoneDescription': tipoLocalidadController.text,
            'locType': tipoUbicacionController.text,
            'posOperator': operadorController.text,
            'posTown': puebloController.text,
            'locDescription': descripcionUbicacionController.text,
          },
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white60, fontSize: 20),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          // suffixIcon: Icon(icon, color: Colors.white54),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required ValueChanged<String?> onChanged,
    double height = 30.0,
  }) {
    List<DropdownMenuItem<String>> dropdownItems;

    if (items is List<String>) {
      dropdownItems = items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList();
    } else if (items is List<DropdownMenuItem<String>>) {
      dropdownItems = items;
    } else {
      throw ArgumentError('Invalid items type');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          // suffixIcon: const Icon(Icons.filter_alt, color: Colors.white54),
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: SizedBox(
            height: height,
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF005954).withOpacity(0.9),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              isExpanded: true,
              value: value,
              items: dropdownItems,
              onChanged: onChanged,
              hint: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
/*
// ignore_for_file: library_private_types_in_public_api, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/constants/towns_list.dart';
import 'package:icc_claro_app/data/models/payload/message_response.dart';
import 'package:icc_claro_app/features/features/map/data/repositories/maps_repository.dart';
import 'package:icc_claro_app/features/features/map/domain/usecases/get_markers_usecase.dart';
import 'package:icc_claro_app/features/features/map/presentation/map_malls_screen.dart';
import 'package:icc_claro_app/features/features/map/presentation/map_pos_screen.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/point_of_sale_repository.dart';

class SearchFormPos extends StatefulWidget {
  const SearchFormPos({super.key});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchFormPos> {
  final TextEditingController idPosController = TextEditingController();
  final TextEditingController idCentroController = TextEditingController();
  final TextEditingController nombrePosController = TextEditingController();
  final TextEditingController nombreMallController = TextEditingController();
  final TextEditingController nombreGerenteController = TextEditingController();
  final TextEditingController direccionPosController = TextEditingController();
  final TextEditingController centroController = TextEditingController();
  final TextEditingController tipoLocalidadController = TextEditingController();
  final TextEditingController tipoUbicacionController = TextEditingController();
  final TextEditingController operadorController = TextEditingController();
  final TextEditingController puebloController = TextEditingController();
  final TextEditingController descripcionUbicacionController =
      TextEditingController();

  bool centrosComerciales = false;

  String? selectedLocalZone;
  String? selectedLocationType;
  String? selectedOperador;
  String? selectedTown;
  String? selectedDescriptionLocation;

  List<String> locationTypes = [];
  List<String> operadores = [];
  List<String> locationDescription = [];
  List<String> localZone = [];
  List<Map<String, dynamic>> allMalls = [];
  List<String> mallNames = [];

  @override
  void initState() {
    super.initState();
    _loadLocationTypes();
    _loadOperadores();
    _loadLocation();
    _loadLocalZone();
    _loadAllMalls();
  }

  Future<void> _loadAllMalls() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.findMalls(context);

      if (response.ok) {
        setState(() {
          allMalls = response.additionalContent.cast<Map<String, dynamic>>();
          mallNames = allMalls
              .map((mall) => mall['group_NAME'] as String)
              .toSet()
              .toList()
            ..sort();
        });
      } else {
        print('Error loading malls: ${response.message}');
      }
    } catch (e) {
      print('Exception loading malls: $e');
    }
  }

  Future<void> _loadLocationTypes() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_TYPE');
      if (response.ok) {
        setState(() {
          locationTypes = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading location types: ${response.message}');
      }
    } catch (e) {
      print('Exception loading location types: $e');
    }
  }

  Future<void> _loadOperadores() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_OPERATOR');
      if (response.ok) {
        setState(() {
          operadores = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading operadores: ${response.message}');
      }
    } catch (e) {
      print('Exception loading operadores: $e');
    }
  }

  Future<void> _loadLocation() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response =
          await client.getPosLovByType('LOC_DESCRIPTION');
      if (response.ok) {
        setState(() {
          locationDescription = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading operadores: ${response.message}');
      }
    } catch (e) {
      print('Exception loading operadores: $e');
    }
  }

  Future<void> _loadLocalZone() async {
    try {
      MapsRepository client = MapsRepository();
      MessageResponse response = await client.getPosLovByType('POS_ZONE');
      if (response.ok) {
        setState(() {
          localZone = (response.content as List)
              .map<String>((item) => item['lovDescription'] as String)
              .toList();
        });
      } else {
        print('Error loading operadores: ${response.message}');
      }
    } catch (e) {
      print('Exception loading operadores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Buscar Puntos de Venta',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey.shade500),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(context, 'Id del Punto de Venta',
                            Icons.search, idPosController),
                        _buildTextField(context, 'Id del Centro Comercial',
                            Icons.search, idCentroController),
                        _buildTextField(context, 'Nombre del Punto de Venta',
                            Icons.search, nombrePosController),
                        _buildTextField(context, 'Nombre del Centro Comercial',
                            Icons.search, nombreMallController),
                        _buildTextField(context, 'Nombre del Gerente',
                            Icons.person, nombreGerenteController),
                        _buildTextField(context, 'Dirección del Punto de Venta',
                            Icons.home, direccionPosController),
                        _buildDropdown(
                          label: 'Zona de Localidad',
                          value: selectedLocalZone,
                          items: localZone,
                          onChanged: (value) {
                            setState(() {
                              selectedLocalZone = value;
                              tipoLocalidadController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Tipo de Ubicación',
                          value: selectedLocationType,
                          items: locationTypes,
                          onChanged: (value) {
                            setState(() {
                              selectedLocationType = value;
                              tipoUbicacionController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Operador',
                          value: selectedOperador,
                          items: operadores,
                          onChanged: (value) {
                            setState(() {
                              selectedOperador = value;
                              operadorController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Pueblo',
                          value: selectedTown,
                          items: townsList,
                          onChanged: (value) {
                            setState(() {
                              selectedTown = value;
                              puebloController.text = value!;
                            });
                          },
                        ),
                        _buildDropdown(
                          label: 'Descripción de Ubicación',
                          value: selectedDescriptionLocation,
                          items: locationDescription,
                          onChanged: (value) {
                            setState(() {
                              selectedDescriptionLocation = value;
                              descripcionUbicacionController.text = value!;
                            });
                          },
                        ),
                        _buildLatLonFields(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PointOfSaleFilteredMapScreen(
                    filters: {
                      'posLocationId': idPosController.text,
                      'idCentro': idCentroController.text,
                      'posLocationName': nombrePosController.text,
                      'posManager': nombreGerenteController.text,
                      'posAddress': direccionPosController.text,
                      'centro': centroController.text,
                      'posZoneDescription': tipoLocalidadController.text,
                      'locType': tipoUbicacionController.text,
                      'operador': operadorController.text,
                      'posTown': puebloController.text,
                      'centrosComerciales': centrosComerciales.toString(),
                      'locDescription': descripcionUbicacionController.text,
                    },
                  ),
                ),
              ),
              elevation: 4,
              backgroundColor: const Color(0xFFb60000).withOpacity(0.7),
              foregroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatLonFields(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Lat',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Lon',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white60, fontSize: 20),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          // suffixIcon: Icon(icon, color: Colors.white54),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required ValueChanged<String?> onChanged,
    double height = 30.0,
  }) {
    List<DropdownMenuItem<String>> dropdownItems;

    if (items is List<String>) {
      dropdownItems = items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList();
    } else if (items is List<DropdownMenuItem<String>>) {
      dropdownItems = items;
    } else {
      throw ArgumentError('Invalid items type');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 20),
          // suffixIcon: const Icon(Icons.filter_alt, color: Colors.white54),
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: SizedBox(
            height: height,
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF005954).withOpacity(0.9),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              isExpanded: true,
              value: value,
              items: dropdownItems,
              onChanged: onChanged,
              hint: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

*/
