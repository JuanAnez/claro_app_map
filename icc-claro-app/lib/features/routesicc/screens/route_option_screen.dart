// route_options_screen.dart
// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:icc_claro_app/features/routesicc/screens/comments_screen.dart';
import 'package:icc_claro_app/features/routesicc/screens/documents_screen.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_detail_screen_to_edit.dart';
import 'package:icc_claro_app/features/routesicc/models/route_model.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_screen.dart';
import 'package:icc_claro_app/features/routesicc/services/close_route.dart';
import 'package:icc_claro_app/features/routesicc/services/route_service.dart';
import 'package:provider/provider.dart';

class RouteOptionsScreen extends StatefulWidget {
  final RouteModel route;
  final RouteModel? model;
  // final User user;
  final String routeType;
  final List<String> roles;
  final Map<String, dynamic>? location;
  final VoidCallback? onReload;

  const RouteOptionsScreen({
    super.key,
    required this.route,
    required this.roles,
    // required this.user,
    required this.routeType,
    this.location,
    this.onReload,
    this.model,
  });

  @override
  State<RouteOptionsScreen> createState() => _RouteOptionsScreenState();
}

class _RouteOptionsScreenState extends State<RouteOptionsScreen> {
  late RouteModel currentRoute;

  bool _isApproved = false;
  bool _isLoading = false;
  bool _isManagerRole(RouteModel route, List<String> roles, String username) {
    return roles.contains('POS_LOC_ADMIN') &&
        route.routeManagerName.trim().toLowerCase() ==
            username.trim().toLowerCase();
  }

  bool _isAssistantRole(RouteModel route, List<String> roles, String username) {
    return roles.contains('POS_LOC_ASSISTANT') &&
        route.routeAssistantName.trim().toLowerCase() ==
            username.trim().toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    currentRoute = widget.route;
  }

  bool isFieldEdited(String fieldName) {
    return currentRoute.modifiedFields != null &&
        currentRoute.modifiedFields![fieldName] == true;
  }

  Future<void> _fetchRouteById() async {
    try {
      final routeService = RouteService();
      final updatedRoute =
          await routeService.fetchRouteById(currentRoute.posLocationRouteID, context: context);

      setState(() {
        currentRoute = updatedRoute;
      });
    } catch (e) {
      print('Error al actualizar el recorrido: $e');
      
      // Mostrar mensaje de error al usuario
      if (mounted) {
        String errorMessage = 'Error al actualizar el recorrido';
        
        if (e.toString().contains('401') || e.toString().contains('Token de autenticación expirado')) {
          errorMessage = 'Sesión expirada. Por favor, inicie sesión nuevamente.';
          // Redirigir al login después de un delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          });
        } else if (e.toString().contains('posLocationID no encontrado')) {
          errorMessage = 'Error en los datos del recorrido. Contacte al administrador.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'No tienes permisos para acceder a este recorrido.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String safeValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'N/A';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          "Información de Recorrido",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showMarkerDetails(
                context,
                widget.location ?? <String, dynamic>{},
                widget.onReload ?? () {},
                routeModel: currentRoute,
              );
            });
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Recorrido: ${currentRoute.posLocationRouteID}',
                      style: TextStyle(
                        color: isFieldEdited('posLocationRouteID')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'ID POS: ${currentRoute.posLocationID}',
                      style: TextStyle(
                        color: isFieldEdited('posLocationID')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Status: ${currentRoute.status}',
                      style: TextStyle(
                        color: isFieldEdited('status')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'POS Info: ${currentRoute.posLocationName}',
                      style: TextStyle(
                        color: isFieldEdited('posLocationName')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Ubicación: ${currentRoute.description ?? currentRoute.locDescription}',
                      style: TextStyle(
                        color: isFieldEdited('locDescription')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Centro Comercial: ${safeValue(currentRoute.locGroupName)}',
                      style: TextStyle(
                        color: isFieldEdited('locGroupName')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Tipo: ${currentRoute.locType}',
                      style: TextStyle(
                        color: isFieldEdited('locType')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Operador: ${currentRoute.posOperator}',
                      style: TextStyle(
                        color: isFieldEdited('posOperator')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Canal: ${currentRoute.channel}',
                      style: TextStyle(
                        color: isFieldEdited('channelId')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Direccion: ${currentRoute.posAddress}',
                      style: TextStyle(
                        color: isFieldEdited('posAddress')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Pueblo: ${currentRoute.posTown}',
                      style: TextStyle(
                        color: isFieldEdited('posTown')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Zona: ${currentRoute.posZone}',
                      style: TextStyle(
                        color: isFieldEdited('posZone')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Desc/Zona: ${currentRoute.posZoneDescription}',
                      style: TextStyle(
                        color: isFieldEdited('posZoneDescription')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Demografico: ${currentRoute.posDemographics}',
                      style: TextStyle(
                        color: isFieldEdited('posDemographics')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Puntuacion: ${currentRoute.posShareMktValue}',
                      style: TextStyle(
                        color: isFieldEdited('posShareMktValue')
                            ? Colors.orange
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: LoadingProgress(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              return isNarrow
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _buildButtons(context, widget.route, widget.roles),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            _buildButtons(context, widget.route, widget.roles)
                                .map((btn) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: btn,
                                    ))
                                .toList(),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButtonHoriz({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 120,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget separetorHoriz() => const SizedBox(width: 16);

  Widget separetorVert() => const SizedBox(height: 16);

  Widget buildBottomButtons(BuildContext context, RouteModel route,
      String routeType, List<String> userProfile) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _buildButtons(context, route, widget.roles),
            );
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildButtons(context, route, widget.roles)
                      .map((button) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: button,
                          ))
                      .toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildButtons(
      BuildContext context, RouteModel route, List<String> roles) {
    List<Widget> buttons = [];
    final user = Provider.of<UserProvider>(context, listen: false).getUser();
    final username = user?.username ?? '';
    final isManager = _isManagerRole(route, roles, username);
    final isAssistant = _isAssistantRole(route, roles, username);
    
    // Debug logging
    print('🔍 Debug _buildButtons:');
    print('  - Username: $username');
    print('  - Roles: $roles');
    print('  - Route ID: ${route.posLocationRouteID}');
    print('  - Route Type: ${widget.routeType}');
    print('  - Is Manager: $isManager');
    print('  - Is Assistant: $isAssistant');

    bool isUser = roles.contains('POS_USER');
    bool isAdmin = roles.contains('POS_ADMIN');
    bool isLocAdmin = roles.contains('POS_LOC_ADMIN');
    bool isLocAssistant = roles.contains('POS_LOC_ASSISTANT');

    void addButtonHoriz(String text, Color color, VoidCallback onPressed) {
      buttons.add(
        _buildDialogButtonHoriz(
          text: text,
          color: color,
          onPressed: onPressed,
        ),
      );
    }

    void addCommonButtons() {
      addButtonHoriz(
        'Coment de\nRecorrido',
        const Color.fromARGB(255, 112, 113, 212),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentsScreen(
                routeId: route.posLocationRouteID,
                location: route.posLocationID,
              ),
            ),
          );
        },
      );

      addButtonHoriz(
        'Docs de\nRecorrido',
        const Color.fromARGB(255, 245, 73, 236),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentsScreen(
                routeId: route.posLocationRouteID,
                locationId: route.posLocationID,
                username: username,
              ),
            ),
          );
        },
      );
    }

    void addMapButton() {
      addButtonHoriz(
        'POS \nMapa',
        const Color.fromARGB(255, 28, 209, 134),
        () {
          final filters = {
            'posLocationId': route.posLocationID.toString(),
          };

          Navigator.pushNamed(
            context,
            '/filtered-map',
            arguments: filters,
          );
        },
      );
    }

    if (isUser && widget.routeType == 'openRoutes') {
      addButtonHoriz(
        'Solicitar\nCierre POS',
        const Color(0xFFb60000),
        () {
          showConfirmationDialog(
            context,
            route.posLocationRouteID,
            () {
              print('Recargar datos después del cierre');
            },
            () {
              Navigator.of(context).pop();
            },
            null,
          );
        },
      );
      addButtonHoriz(
        'Aprobar\nRecorrido',
        const Color(0xFF449D44),
        () async {
          if (_isApproved) {
            _showCustomDialog(
                context, "Advertencia", "Este recorrido ya ha sido aprobado.");
            return;
          }

          final routeService = RouteService();
          try {
            final resultMessage = await routeService.submitSingleRoute(
              context: context,
              route: route,
              username: username,
              roles: roles,
            );

            setState(() {
              _isApproved = true;
            });

            _showSuccessSnackBar(context,
                message: 'Recorrido aprobado exitosamente.');
            Navigator.of(context).pop(true);
          } catch (e) {
            _showCustomDialog(context, "Error", e.toString());
          }
        },
      );
      addButtonHoriz(
        'Editar\nRecorrido',
        const Color(0xFFEC971F),
        () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreenToEdit(route: route),
            ),
          );
          if (result == true) {
            await _fetchRouteById();
          }
        },
      );
      addCommonButtons();
      addMapButton();
    }

    if (isUser && widget.routeType == 'workedRoutes') {
      addButtonHoriz(
        'Editar\nRecorrido',
        const Color(0xFFEC971F),
        () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreenToEdit(route: route),
            ),
          );
          if (result == true) {
            await _fetchRouteById();
          }
        },
      );
      addCommonButtons();
    }

    if ((isLocAdmin || isLocAssistant) && widget.routeType == 'incomingRoutes') {
      if (isManager || isAssistant) {
        addButtonHoriz(
          'Editar\nRecorrido',
          const Color(0xFFEC971F),
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreenToEdit(route: route),
              ),
            );
            if (result == true) {
              await _fetchRouteById();
            }
          },
        );
        addCommonButtons();
      } else {
        addButtonHoriz(
          'Editar\nRecorrido',
          const Color(0xFFEC971F),
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreenToEdit(route: route),
              ),
            );
            if (result == true) {
              await _fetchRouteById();
            }
          },
        );
        addCommonButtons();
      }
    }

    if ((isLocAdmin || isLocAssistant) && widget.routeType == 'openRoutes') {
      if (isManager || isAssistant) {
        addButtonHoriz(
          'Aprobar\nRecorrido',
          const Color(0xFF449D44),
          () async {
            if (_isApproved) {
              _showCustomDialog(context, "Advertencia",
                  "Este recorrido ya ha sido aprobado.");
              return;
            }

            final routeService = RouteService();

            try {
              final resultMessage = await routeService.submitSingleRoute(
                context: context,
                route: route,
                username: username,
                roles: roles,
              );

              setState(() {
                _isApproved = true;
              });

              _showSuccessSnackBar(context,
                  message: 'Recorrido aprobado exitosamente.');
            } catch (e) {
              _showCustomDialog(context, "Error", e.toString());
            }
          },
        );
        addButtonHoriz(
          'Devolver\nRecorrido',
          const Color(0xFFb60000),
          () async {
            if (_isApproved) {
              _showCustomDialog(
                  context, "Advertencia", "Este recorrido ha sido devuelto.");
              return;
            }

            final routeService = RouteService();

            try {
              final resultMessage = await routeService.returnSingleRoute(
                route: route,
                username: username,
                roles: roles,
                context: context,
              );

              setState(() {
                _isApproved = true;
              });

              _showSuccessSnackBar(context,
                  message: 'Recorrido devuelto correctamente.');
            } catch (e) {
              _showCustomDialog(context, "Error", e.toString());
            }
          },
        );
        addButtonHoriz(
          'Editar\nRecorrido',
          const Color(0xFFEC971F),
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreenToEdit(route: route),
              ),
            );

            if (result == true) {
              final routeService = RouteService();
              final updatedRoute =
                  await routeService.fetchRouteById(route.posLocationRouteID, context: context);

              setState(() {
                route = updatedRoute;
              });
            }
          },
        );
        addCommonButtons();
        addMapButton();
      } else {
        addButtonHoriz(
          'Aprobar\nRecorrido',
          const Color(0xFF449D44),
          () async {
            if (_isApproved) {
              _showCustomDialog(context, "Advertencia",
                  "Este recorrido ya ha sido aprobado.");
              return;
            }

            final routeService = RouteService();

            try {
              final resultMessage = await routeService.submitSingleRoute(
                route: route,
                username: username,
                roles: roles,
                context: context,
              );

              setState(() {
                _isApproved = true;
              });

              _showSuccessSnackBar(context,
                  message: 'Recorrido aprobado exitosamente.');
            } catch (e) {
              _showCustomDialog(context, "Error", e.toString());
            }
          },
        );
        addButtonHoriz(
          'Devolver\nRecorrido',
          const Color(0xFFb60000),
          () async {
            if (_isApproved) {
              _showCustomDialog(
                  context, "Advertencia", "Este recorrido ha sido devuelto.");
              return;
            }

            final routeService = RouteService();

            try {
              final resultMessage = await routeService.returnSingleRoute(
                route: route,
                username: username,
                roles: roles,
                context: context,
              );

              setState(() {
                _isApproved = true;
              });

              _showSuccessSnackBar(context,
                  message: 'Recorrido devuelto correctamente.');
            } catch (e) {
              _showCustomDialog(context, "Error", e.toString());
            }
          },
        );
        addButtonHoriz(
          'Editar\nRecorrido',
          const Color(0xFFEC971F),
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreenToEdit(route: route),
              ),
            );
            if (result == true) {
              await _fetchRouteById();
            }
          },
        );
        addCommonButtons();
        addMapButton();
      }
    }

    if ((isLocAdmin || isLocAssistant) && widget.routeType == 'workedRoutes') {
      if (isManager || isAssistant) {
        addButtonHoriz(
          'Editar\nRecorrido',
          const Color(0xFFEC971F),
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreenToEdit(route: route),
              ),
            );
            if (result == true) {
              await _fetchRouteById();
            }
          },
        );
        addCommonButtons();
      } else {
        addButtonHoriz(
          'Editar\nRecorrido',
          const Color(0xFFEC971F),
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreenToEdit(route: route),
              ),
            );
            if (result == true) {
              await _fetchRouteById();
            }
          },
        );
        addCommonButtons();
      }
    }

    if (isAdmin && widget.routeType == 'incomingRoutes') {
      addButtonHoriz(
        'Editar\nRecorrido',
        const Color(0xFFEC971F),
        () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreenToEdit(route: route),
            ),
          );
          if (result == true) {
            await _fetchRouteById();
          }
        },
      );
      addCommonButtons();
    }

    if (isAdmin && widget.routeType == 'openRoutes') {
      addButtonHoriz(
        'Cancelar\nRecorrido',
        const Color(0xFFb60000),
        () async {
          if (_isApproved) {
            _showCustomDialog(
                context, "Advertencia", "Este recorrido ya ha sido cancelado.");
            return;
          }
          
          setState(() {
            _isLoading = true;
          });

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final username = userProvider.getUser()?.username ?? 'default_user';
          final routeService = RouteService();

          try {
            final result = await routeService.cancelRoute(
              routeId: route.posLocationRouteID,
              userName: username,
              context: context,
            );

            setState(() {
              _isApproved = true;
            });
            // _showCustomDialog(context, "Éxito", result);
            _showSuccessSnackBar(context,
                message: 'Recorrido cancelado correctamente.');
          } catch (e) {
            _showCustomDialog(context, "Error", e.toString());
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
      addButtonHoriz(
        'Cerrar\nPOS',
        const Color(0xFFb60000),
        () async {
          if (_isApproved) {
            _showCustomDialog(
                context, "Advertencia", "Este recorrido ya ha sido cerrado.");
            return;
          }
          
          setState(() {
            _isLoading = true;
          });

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final username = userProvider.getUser()?.username ?? 'default_user';
          final routeService = RouteService();

          try {
            final result = await routeService.closeRoute(
              routeId: route.posLocationRouteID,
              userName: username,
              context: context,
            );

            setState(() {
              _isApproved = true;
            });
            // _showCustomDialog(context, "Éxito", result);
            _showSuccessSnackBar(context,
                message: 'Punto de venta cerrado correctamente.');
          } catch (e) {
            _showCustomDialog(context, "Error", e.toString());
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
      addButtonHoriz(
        'Validar\nRecorrido',
        const Color(0xFF449D44),
        () async {
          if (_isApproved) {
            _showCustomDialog(
                context, "Advertencia", "Este recorrido ya ha sido aprobado.");
            return;
          }

          setState(() {
            _isLoading = true;
          });

          final routeService = RouteService();

          try {
            final resultMessage = await routeService.submitSingleRoute(
              context: context,
              route: route,
              username: username,
              roles: roles,
            );

            setState(() {
              _isApproved = true;
            });

            _showCustomDialog(context, "Éxito", resultMessage);
          } catch (e) {
            _showCustomDialog(context, "Error", e.toString());
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
      addButtonHoriz(
        'Devolver\nRecorrido',
        const Color(0xFFb60000),
        () async {
          if (_isApproved) {
            _showCustomDialog(
                context, "Advertencia", "Este recorrido ha sido devuelto.");
            return;
          }

          final routeService = RouteService();

          try {
            final resultMessage = await routeService.returnSingleRoute(
              route: route,
              username: username,
              roles: roles,
              context: context,
            );

            setState(() {
              _isApproved = true;
            });

            _showSuccessSnackBar(context,
                message: 'Recorrido devuelto correctamente.');
          } catch (e) {
            _showCustomDialog(context, "Error", e.toString());
          }
        },
      );
      addButtonHoriz(
        'Editar\nRecorrido',
        const Color(0xFFEC971F),
        () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreenToEdit(route: route),
            ),
          );

          if (result == true) {
                          final routeService = RouteService();
              final updatedRoute =
                  await routeService.fetchRouteById(route.posLocationRouteID, context: context);

            setState(() {
              route = updatedRoute;
            });
          }
        },
      );
      addCommonButtons();
      addMapButton();
    }

    if (isAdmin && widget.routeType == 'workedRoutes') {
      addButtonHoriz(
        'Editar\nRecorrido',
        const Color(0xFFEC971F),
        () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreenToEdit(route: route),
            ),
          );
          if (result == true) {
            await _fetchRouteById();
          }
        },
      );
      addCommonButtons();
    }

    return buttons;
  }
}

void _showSuccessSnackBar(BuildContext context,
    {required String message, VoidCallback? onReload}) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );

    if (onReload != null) {
      onReload();
    }

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(true);
    });
  }
}

void _showCustomDialog(BuildContext context, String title, String message) {
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
                  Navigator.of(context).pop(true);
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

class User {
  final List<String> authorities;

  User({required this.authorities});
}

void showConfirmationDialog(
  BuildContext context,
  int posLocationRouteID,
  VoidCallback onReload,
  VoidCallback? onCancel,
  Map<String, dynamic>? location,
) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final user = userProvider.getUser();
  final userAuthorities = user?.authorities;

  if (!hasAdminPermission(userAuthorities)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFb60000),
        content: Text(
          'No tienes permiso para cerrar este punto de venta.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 5),
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: SingleChildScrollView(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Estás seguro de que quieres cerrar el punto de venta?',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AlertButton(
                        text: 'Cancelar',
                        onPressed: () {
                          final safeContext =
                              Navigator.of(context).overlay!.context;
                          Navigator.of(context).pop();

                          if (location != null) {
                            Future.microtask(() {
                              showMarkerDetails(safeContext, location, onReload,
                                  routeModel: null);
                              print('🛑 Keys disponibles: ${location.keys}');
                            });
                          } else if (onCancel != null) {
                            Future.microtask(() => onCancel());
                          }
                        },
                        color: const Color(0xFFb60000),
                      ),
                      AlertButton(
                        text: 'Confirmar',
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.microtask(() {
                            showReasonDialog(
                              context,
                              posLocationRouteID,
                              onReload,
                              () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RouteScreen(
                                        routeType: 'openRoutes'),
                                  ),
                                );
                              },
                            );
                          });
                        },
                        color: const Color(0xFF449D44),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

bool hasAdminPermission(dynamic authorities) {
  if (authorities == null) return false;

  try {
    if (authorities is String) {
      final decoded = jsonDecode(authorities);
      if (decoded is Map && decoded.containsKey('message')) {
        return decoded['message'].contains('POS_USER');
      }
    }
    if (authorities is Map && authorities.containsKey('message')) {
      return authorities['message'].contains('POS_USER');
    }
  } catch (e) {
    print("Error decoding authorities: $e");
  }

  return false;
}

void showReasonDialog(BuildContext context, int posLocationRouteID,
    VoidCallback onReload, VoidCallback onSuccessNavigate) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CloseRoute(
        posLocationRouteID: posLocationRouteID,
        onReload: onReload,
        onSuccessNavigate: onSuccessNavigate,
      );
    },
  );
}
