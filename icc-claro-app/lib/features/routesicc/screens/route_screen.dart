// ignore_for_file: library_private_types_in_public_api, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/helpers/get_roles.dart';
import 'package:icc_claro_app/core/utils/helpers/immersive_loader.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_detail_create_screen.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_option_screen.dart';
import 'package:provider/provider.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

class RouteScreen extends StatefulWidget {
  final String routeType;
  const RouteScreen({super.key, required this.routeType});

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final RouteService _routeService = RouteService();
  List<RouteModel> _routes = [];
  List<RouteModel> _filteredRoutes = [];
  bool _isLoading = true;
  String _searchQuery = "";
  bool _selectionMode = false;
  Set<int> _selectedRouteIds = {};

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  bool isPosUser(List<String> roles) => roles.contains('POS_USER');
  bool isPosAdmin(List<String> roles) => roles.contains('POS_ADMIN');
  bool isLocAdmin(List<String> roles) => roles.contains('POS_LOC_ADMIN');
  bool isLocAssistant(List<String> roles) =>
      roles.contains('POS_LOC_ASSISTANT');

  bool isManagerRole(RouteModel route, List<String> roles) {
    return isLocAdmin(roles) && route.routeManagerId > 0;
  }

  bool isAssistantRole(RouteModel route, List<String> roles) {
    return isLocAssistant(roles) && route.routeAssistantId > 0;
  }

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
    _horizontalScrollController.addListener(() {
      _horizontalHeaderController.jumpTo(_horizontalScrollController.offset);
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _horizontalHeaderController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoutes() async {
    try {
      List<RouteModel> routes = await _routeService.fetchRoutes(
          context: context, routeType: widget.routeType);
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _filteredRoutes = routes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print("Error fetching routes: $e");
    }
  }

  void _filterRoutes(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredRoutes = _routes.where((route) {
        return route.posLocationRouteID.toString().contains(_searchQuery) ||
            route.posLocationID.toString().contains(_searchQuery) ||
            route.posLocationInfo.toLowerCase().contains(_searchQuery) ||
            route.status.toLowerCase().contains(_searchQuery) ||
            route.routeExpectedCloseDate.toLowerCase().contains(_searchQuery) ||
            route.creationDate.toLowerCase().contains(_searchQuery) ||
            route.updatedBy.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().getUser();
    final roles = getRolesFromAuthorities(user?.authorities);
    final visibleColumns = _filteredRoutes.isNotEmpty
        ? getColumnsForRoleAndType(
            _filteredRoutes.first, roles, widget.routeType)
        : [];
    final double cellWidth = 180;
    final double tableWidth = visibleColumns.length * cellWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.routeType == 'incomingRoutes'
              ? 'Recorridos en Proceso - ${_filteredRoutes.length}'
              : widget.routeType == 'openRoutes'
                  ? 'Recorridos Abiertos - ${_filteredRoutes.length}'
                  : widget.routeType == 'workedRoutes'
                      ? 'Recorridos Trabajados - ${_filteredRoutes.length}'
                      : 'Lista de Recorridos ',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC21618),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    labelStyle: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70, width: 2),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterRoutes,
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalHeaderController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: tableWidth),
                    child: Row(
                      children: visibleColumns
                          .map((col) => _buildHeaderCell(col, width: cellWidth))
                          .toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: LoadingProgress())
                    : _filteredRoutes.isEmpty
                        ? const Center(
                            child: Text('No hay recorridos disponibles',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)))
                        : Scrollbar(
                            controller: _horizontalScrollController,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _horizontalScrollController,
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: tableWidth),
                                child: Scrollbar(
                                  controller: _verticalScrollController,
                                  child: ListView.builder(
                                    controller: _verticalScrollController,
                                    itemCount: _filteredRoutes.length,
                                    itemBuilder: (context, index) {
                                      final route = _filteredRoutes[index];
                                      final isSelected = _selectedRouteIds
                                          .contains(route.posLocationRouteID);
                                      return InkWell(
                                        onTap: () {
                                          if (_selectionMode) {
                                            _toggleSelection(
                                                route.posLocationRouteID);
                                            return;
                                          }
                                          if ([
                                            "incomingRoutes",
                                            "openRoutes",
                                            "workedRoutes"
                                          ].contains(widget.routeType)) {
                                            _showEditOptionsUser(context, route,
                                                widget.routeType);
                                          }
                                        },
                                        onLongPress: widget.routeType ==
                                                'openRoutes'
                                            ? () {
                                                setState(() {
                                                  _selectionMode = true;
                                                  _selectedRouteIds.add(
                                                      route.posLocationRouteID);
                                                });
                                              }
                                            : null,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.green.withOpacity(0.6)
                                                : (index.isEven
                                                    ? Colors.white
                                                    : Colors.grey.shade300),
                                            border: Border(
                                                bottom: BorderSide(
                                                    color:
                                                        Colors.grey.shade300)),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 10.0),
                                          child: SingleChildScrollView(
                                            child: IntrinsicWidth(
                                              stepWidth: cellWidth,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: visibleColumns
                                                    .map((col) => Flexible(
                                                          child: _buildTableCell(
                                                              getValueForColumn(
                                                                  col, route),
                                                              width: cellWidth),
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
          if (_isLoading)
            const ModalBarrier(
              dismissible: false,
            ),
          if (_isLoading) const Center(child: LoadingProgress()),
          if (widget.routeType == 'openRoutes' && roles.contains('POS_USER'))
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Color(0xFFb60000).withOpacity(0.1),
                foregroundColor: Colors.white.withOpacity(0.7),
                onPressed: () async {
                  if (roles.contains('POS_USER')) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RouteDetailCreateScreen(),
                      ),
                    );
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Punto de venta creado correctamente')),
                      );
                      await _fetchRoutes();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No routes available to edit')),
                    );
                  }
                },
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: _selectedRouteIds.isEmpty
                      ? null
                      : () => _submitBatch(context, null),
                  label: Text(
                    roles.contains('POS_USER')
                        ? "Recorrido Trabajado"
                        : (roles.contains('POS_LOC_ADMIN') ||
                                roles.contains('POS_LOC_ASSISTANT'))
                            ? "Aprobar Recorrido"
                            : roles.contains('POS_ADMIN')
                                ? "Validar Recorrido"
                                : "Validar Recorrido",
                  ),
                  icon: const Icon(Icons.check),
                  backgroundColor: Colors.green,
                ),
                if (widget.routeType == 'openRoutes' &&
                    (roles.contains('POS_LOC_ADMIN') ||
                        roles.contains('POS_LOC_ASSISTANT')))
                  const SizedBox(width: 12),
                if (widget.routeType == 'openRoutes' &&
                    (roles.contains('POS_LOC_ADMIN') ||
                        roles.contains('POS_LOC_ASSISTANT')))
                  FloatingActionButton.extended(
                    onPressed: _selectedRouteIds.isEmpty
                        ? null
                        : () => _returnRoutesToPosUser(context),
                    label: const Text("Devolver Recorrido"),
                    icon: const Icon(Icons.reply),
                    backgroundColor: Colors.redAccent,
                  ),
              ],
            )
          : null,
    );
  }

  void _submitBatch(BuildContext context, VoidCallback? onReload) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userName = userProvider.getUser()?.username ?? 'DEFAULT_USER';
    final authorities = userProvider.getUser()?.authorities ?? '';
    print('Authorities: $authorities');
    final roles = getRolesFromAuthorities(authorities);

    final routeService = RouteService();
    final routeIdsList = _selectedRouteIds.toList();

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await routeService.submitBatch(
          routeIds: routeIdsList,
          userName: userName,
          roles: roles,
          anyRoute: _filteredRoutes
              .firstWhere((r) => r.posLocationRouteID == routeIdsList.first),
          currentUsername: userName,
          context: context);

      _showDialog(context, "Éxito", message);
      await _fetchRoutes();
      setState(() {
        _selectionMode = false;
        _selectedRouteIds.clear();
      });
    } catch (e) {
      _showDialog(context, "Error", e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _returnRoutesToPosUser(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userName = userProvider.getUser()?.username ?? 'DEFAULT_USER';
    final routeService = RouteService();
    final routeIdsList = _selectedRouteIds.toList();

    if (routeIdsList.isEmpty) {
      _showDialog(context, "Error", "Debes seleccionar al menos un recorrido.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await routeService.returnRoutesToPosUser(
        routeIds: routeIdsList,
        context: context,
      );

      _showDialog(context, "Éxito", message);
      await _fetchRoutes();
      setState(() {
        _selectionMode = false;
        _selectedRouteIds.clear();
      });
    } catch (e) {
      _showDialog(context, "Error", e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.only(
                top: 30.0, left: 30.0, right: 30.0, bottom: 20.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFb60000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedRouteIds.contains(id)) {
        _selectedRouteIds.remove(id);
        if (_selectedRouteIds.isEmpty) _selectionMode = false;
      } else {
        _selectedRouteIds.add(id);
      }
    });
  }

  _showEditOptionsUser(
      BuildContext context, RouteModel route, String routeType) async {
    final user = context.read<UserProvider>().getUser();
    final roles = getRolesFromAuthorities(user?.authorities);

    try {
      await withImmersiveLoader(context, () async {
        final updatedRoute = await _routeService
            .fetchRouteById(route.posLocationRouteID, context: context);

        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => RouteOptionsScreen(
              route: updatedRoute,
              roles: roles,
              routeType: widget.routeType,
            ),
          ),
        );
      });

      if (mounted) {
        setState(() => _isLoading = true);
        await _fetchRoutes();
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "No se pudo cargar el recorrido actualizado";
      if (e.toString().contains('401') ||
          e.toString().contains('Token de autenticación expirado')) {
        errorMessage = "Sesión expirada. Por favor, inicie sesión nuevamente.";
      } else if (e.toString().contains('posLocationID no encontrado')) {
        errorMessage =
            "Error en los datos del recorrido. Contacte al administrador.";
      } else if (e.toString().contains('403')) {
        errorMessage = "No tienes permisos para acceder a este recorrido.";
      }

      _showDialog(context, "Error", errorMessage);
    }
  }

  Widget _buildTableCell(String text, {double width = 180}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildHeaderCell(String text, {double width = 180}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.clip,
        maxLines: 2,
      ),
    );
  }

  List<String> getColumnsForRole(RouteModel route, List<String> roles) {
    List<String> columns = [
      'ID Recorrido',
      'ID POS',
      'Status',
      'POS Info',
      'Ubicación',
      'Centro Comercial',
      'Tipo',
      'Operador',
      'Canal',
      'Direccion',
      'Pueblo',
      'Lat',
      'Long',
      'Gte. Distrito',
      'Asistente',
      'Cod. Agente',
      'Cod. Local',
      'Fecha Asignado',
      'Asignado A',
      'Aging',
      'Aging Gerente',
      'Aging Actual'
    ];

    if (isPosUser(roles)) {
      // POS User
      columns.addAll([
        'Fecha Recorrido',
        // 'Asignado A',
        'Aging',
        'Aging Actual',
        'Aging Gerente'
      ]);
    } else if (isManagerRole(route, roles)) {
      // Manager
      columns.addAll([
        'Fecha Recorrido',
        'Encargado',
        'Tipo Encargado',
        'Fecha Asistente',
        'Aging Asistente',
        'Asistente',
        'Tipo Asistente',
        'Fecha Gerente',
        'Aging Gerente',
        'Gerente',
        'Tipo Gerente',
        'Encargado Actual',
        'Fecha Actual',
        'Aging Actual',
      ]);
    } else if (isLocAssistant(roles)) {
      // Local Assistant
      if (isAssistantRole(route, roles)) {
        columns.addAll([
          'Fecha Recorrido',
          // 'Aging Encargado',
          'Encargado',
          'Tipo Recorrido',
          // 'Fecha Asistente',
          'Aging Asistente',
          // 'Asistente',
          // 'Tipo Asistente',
          // 'Fecha Gerente',
          'Aging Gerente',
          'Gerente',
          'Tipo Gerente',
          'Encargado Actual',
          'Fecha Actual',
          'Aging Actual',
        ]);
      } else {
        columns.addAll([
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Aprobación',
          'Asistente',
          'Tipo Asistente',
          'Encargado Actual',
          'Fecha Actual',
          'Aging Actual',
        ]);
      }
    } else if (isPosAdmin(roles)) {
      // POS Admin
      columns.addAll([
        'Zona',
        'Desc/Zona',
        'Demografico',
        'Puntuacion',
        'Fecha Recorrido',
        'Aging Encargado',
        'Encargado',
        'Tipo Encargado',
        'Fecha Aprobación Asistente',
        'Aging Asistente',
        'Asistente',
        'Tipo Asistente',
        'Fecha Aprobación Gerente',
        'Aging Gerente',
        'Gerente',
        'Tipo Gerente',
        'Fecha Actual',
        'Encargado Actual',
        'Aging Actual',
        'Cumplimiento',
      ]);
    }

    return columns;
  }

  Set<String> _columnsForType(String routeType) {
    switch (routeType) {
      case 'incomingRoutes':
        return {
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Aging Gerente',
          'Aging',
          'Aging Asistente',
        };

      case 'openRoutes':
        return {
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Encargado',
          'Fecha Aprobación',
          'Asistente',
          'Tipo Asistente',
          'Fecha Aprobación Asistente',
          'Gerente',
          'Tipo Gerente',
          'Fecha Aprobación Gerente',
          'Encargado Actual',
          'Fecha Actual',
          'Aging Actual',
        };

      case 'workedRoutes':
        return {
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Asistente',
          'Tipo Asistente',
          'Gerente',
          'Tipo Gerente',
          'Encargado Actual',
          'Fecha Actual',
          'Aging Actual',
          'Cumplimiento',
          'Fecha Asignado',
          'Asignado A',
          'Aging',
          'Aging Asistente',
          'Aging Gerente',
        };

      default:
        return {};
    }
  }

  List<String> getColumnsForRoleAndType(
    RouteModel route,
    List<String> roles,
    String routeType,
  ) {
    // POS_USER
    if (isPosUser(roles)) {
      if (routeType == 'openRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
        ];
      } else if (routeType == 'workedRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Asignado',
          'Asignado A',
          'Aging Actual',
        ];
      }
    }

    // POS_LOC_ASSISTANT
    if (isLocAssistant(roles)) {
      if (routeType == 'incomingRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Tipo Recorrido',
          'Aging',
        ];
      } else if (routeType == 'openRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
        ];
      } else if (routeType == 'workedRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Tipo Recorrido',
          'Aging',
          'Fecha Asignado',
          'Asignado A',
          'Aging Actual',
        ];
      }
    }

    // POS_LOC_ADMIN
    if (isLocAdmin(roles)) {
      if (routeType == 'incomingRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Asistente',
          'Aging Encargado',
          'Asistente N.',
          'Tipo Asistente',
          'Aging Asistente',
        ];
      } else if (routeType == 'openRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Asistente',
          'Asistente N.',
          'Tipo Asistente',
        ];
      } else if (routeType == 'workedRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Asistente',
          'Aging Encargado',
          'Asistente N.',
          'Tipo Asistente',
          'Aging Asistente',
          'Fecha Asignado',
          'Asignado A',
          'Aging Actual',
        ];
      }
    }

    // POS_ADMIN
    if (isPosAdmin(roles)) {
      if (routeType == 'incomingRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Cod. Agente',
          'Cod. Local',
          'Zona',
          'Desc/Zona',
          'Demografico',
          'Puntuacion',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Asistente',
          'Aging Encargado',
          'Asistente N.',
          'Tipo Asistente',
          'Fecha Gerente',
          'Aging Asistente',
          'Gerente',
          'Tipo Gerente',
          'Aging Gerente',
        ];
      } else if (routeType == 'openRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Asistente',
          'Cod. Agente',
          'Cod. Local',
          'Zona',
          'Desc/Zona',
          'Demografico',
          'Puntuacion',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Asistente',
          'Asistente N.',
          'Tipo Asistente',
          'Fecha Asignado',
          'Gerente',
          'Tipo Gerente',
        ];
      } else if (routeType == 'workedRoutes') {
        return [
          'ID Recorrido',
          'ID POS',
          'Status',
          'POS Info',
          'Ubicación',
          'Centro Comercial',
          'Tipo',
          'Operador',
          'Canal',
          'Direccion',
          'Pueblo',
          'Lat',
          'Long',
          'Gte. Distrito',
          'Cod. Agente',
          'Cod. Local',
          'Zona',
          'Desc/Zona',
          'Demografico',
          'Puntuacion',
          'Fecha Recorrido',
          'Encargado',
          'Tipo Recorrido',
          'Fecha Asistente',
          'Aging Encargado',
          'Asistente N.',
          'Tipo Asistente',
          'Fecha Gerente',
          'Aging Asistente',
          'Gerente',
          'Tipo Gerente',
          'Aging Gerente',
          'Fecha Asignado',
          'Asignado A',
          'Aging Actual',
          'Cumplimiento',
        ];
      }
    }

    // Fallback: retornar columnas básicas si no coincide ningún caso
    return [
      'ID Recorrido',
      'ID POS',
      'Status',
      'POS Info',
      'Ubicación',
      'Centro Comercial',
      'Tipo',
      'Operador',
      'Canal',
      'Direccion',
      'Pueblo',
      'Lat',
      'Long',
      'Gte. Distrito',
      'Asistente',
      'Cod. Agente',
      'Cod. Local',
    ];
  }

  String getValueForColumn(String column, RouteModel route) {
    switch (column) {
      case 'ID Recorrido':
        return route.posLocationRouteID.toString();
      case 'ID POS':
        return route.posLocationID.toString();
      case 'Status':
        return route.status;
      case 'POS Info':
        return route.posLocationInfo;
      case 'Ubicación':
        return route.locDescription;
      case 'Centro Comercial':
        return route.locGroupName ?? 'N/A';
      case 'Tipo':
        return route.locType;
      case 'Operador':
        return route.posOperator;
      case 'Canal':
        return route.channel;
      case 'Direccion':
        return route.posAddress;
      case 'Pueblo':
        return route.posTown;
      case 'Lat':
        return route.latitude.toString();
      case 'Long':
        return route.longitude.toString();
      case 'Gte. Distrito':
        return route.posManager?.toString() ?? 'N/A';
      case 'Asistente':
        return route.posAssistant?.toString() ?? 'N/A';
      case 'Cod. Agente':
        return route.posDealer?.toString() ?? 'N/A';
      case 'Cod. Local':
        return route.posLocationCode?.toString() ?? 'N/A';
      case 'Fecha Recorrido':
        return route.creationDate;
      case 'Tipo Recorrido':
        return route.routeTypeAssigned;
      case 'Aging':
        return route.aging;
      case 'Encargado':
        return route.routeAssignedName;
      case 'Fecha Asistente':
        return route.approvalAssignedDate;
      case 'Tipo Asistente':
        return route.routeTypeAssistant;
      case 'Aging Encargado':
        return route.agingRouteAssigned;
      case 'Aging Asistente':
        return route.agingRouteAssistant;
      case 'Fecha Actual':
        return route.approvalManagerDate;
      case 'Asignado A':
        return route.currentlyAssignedToName;
      case 'Aging Actual':
        return route.currentlyAging;
      case 'Fecha Asignado':
        return route.approvalAssignedDate;
      case 'Zona':
        return route.posZone;
      case 'Desc/Zona':
        return route.posZoneDescription;
      case 'Demografico':
        return route.posDemographics;
      case 'Puntuacion':
        return route.posShareMktValue.toString();
      case 'Fecha Gerente':
        return route.approvalManagerDate;
      case 'Gerente':
        return route.routeManagerName;
      case 'Tipo Gerente':
        return route.routeTypeManager;
      case 'Aging Gerente':
        return route.agingRouteManager;
      case 'Cumplimiento':
        return route.cumplimiento;
      case 'Asistente N.':
        return route.routeAssistantName;
      default:
        return 'N/A';
    }
  }

  List<String> _intersectOrdered(List<String> source, Set<String> allowed) {
    return source.where((c) => allowed.contains(c)).toList();
  }
}
