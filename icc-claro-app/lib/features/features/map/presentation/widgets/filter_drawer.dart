import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'dart:convert';

import 'package:icc_claro_app/features/features/providers/point_of_sale_providers.dart';
import 'package:provider/provider.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late Future<Map<String, dynamic>> _dropdownInputsFuture;
  final Map<String, bool> _selectedPosTypes = {};
  final Map<String, bool> _selectedOperators = {};

  @override
  void initState() {
    super.initState();
    _dropdownInputsFuture = fetchDropdownInputs(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<PointOfSaleProvider>();

    for (var id in provider.activePosTypeIds) {
      _selectedPosTypes[id] = true;
    }

    for (var id in provider.activeOperatorIds) {
      _selectedOperators[id] = true;
    }
  }

  Future<Map<String, dynamic>> fetchDropdownInputs(BuildContext context) async {
    final typesResp = await HttpAuthService.authenticatedGet(
      ApiEndpoints.getPosLovByType,
      queryParameters: {'lovType': 'POS_TYPE'},
      context: context,
    );
    final opsResp = await HttpAuthService.authenticatedGet(
      ApiEndpoints.getPosLovByType,
      queryParameters: {'lovType': 'POS_OPERATOR'},
      context: context,
    );

    final decodedTypes = jsonDecode(typesResp.body);
    if (decodedTypes is! List) {
      throw Exception(
        'Esperaba lista para POS_TYPE. Status ${typesResp.statusCode}. Body: ${typesResp.body}',
      );
    }

    final decodedOps = jsonDecode(opsResp.body);
    if (decodedOps is! List) {
      throw Exception(
        'Esperaba lista para POS_OPERATOR. Status ${opsResp.statusCode}. Body: ${opsResp.body}',
      );
    }

    return {
      'allPosTypes': decodedTypes,
      'allPosOperators': decodedOps,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _dropdownInputsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingProgress());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final List posTypes = data['allPosTypes'] ?? [];
          final List posOperators = data['allPosOperators'] ?? [];

          final filteredPosTypes =
              posTypes.where((e) => e['lovGroup'] != 'GC').toList();

          for (var type in filteredPosTypes) {
            _selectedPosTypes.putIfAbsent(
                type['lovId'].toString(), () => false);
          }
          for (var op in posOperators) {
            _selectedOperators.putIfAbsent(op['lovId'].toString(), () => false);
          }

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFFb60000),
                    ),
                    child: Text('Tipos de Localidad',
                        style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    child: Text('Tipos de POS',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...filteredPosTypes.map<Widget>((type) {
                    final id = type['lovId'].toString();

                    return ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(type['lovDescription'] ?? ''),
                      trailing: Switch(
                        activeColor: const Color(0xFFb60000),
                        value: _selectedPosTypes[id] ?? false,
                        onChanged: (val) {
                          setState(() {
                            _selectedPosTypes[id] = val;
                          });
                        },
                      ),
                    );
                  }),
                  const Divider(),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    child: Text('Operadores',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...posOperators.map<Widget>((op) {
                    final id = op['lovId'].toString();
                    return ListTile(
                      leading: const Icon(Icons.mobile_friendly),
                      title: Text(op['lovDescription'] ?? ''),
                      trailing: Switch(
                        activeColor: const Color(0xFFb60000),
                        value: _selectedOperators[id] ?? false,
                        onChanged: (val) {
                          setState(() {
                            _selectedOperators[id] = val;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 80,
                child: FloatingActionButton(
                  heroTag: "btn_filter_drawer",
                  backgroundColor: Color(0xFFb60000),
                  onPressed: () async {
                    final selectedPosTypes = _selectedPosTypes.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();

                    final selectedOperators = _selectedOperators.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();

                    final provider = context.read<PointOfSaleProvider>();
                    provider.updateActiveFilters(
                      posTypeIds: selectedPosTypes,
                      operatorIds: selectedOperators,
                    );

                    final filters = <String, String>{};
                    if (selectedPosTypes.isNotEmpty) {
                      filters['posTypeId'] = selectedPosTypes.join(',');
                    }
                    if (selectedOperators.isNotEmpty) {
                      filters['posOperatorId'] = selectedOperators.join(',');
                    }

                    if (mounted) Navigator.pop(context);

                    Navigator.pushNamed(
                      context,
                      '/filtered-map',
                      arguments: filters,
                    );
                  },
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
