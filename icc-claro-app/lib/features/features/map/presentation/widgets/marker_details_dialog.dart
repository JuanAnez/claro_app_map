import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/core/widgets/pos_contacts_list.dart';
import 'package:icc_claro_app/core/widgets/pos_files_list.dart';
import 'package:icc_claro_app/core/widgets/reason_dialog.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/routesicc/models/route_model.dart';
import 'package:icc_claro_app/features/routesicc/screens/route_option_screen.dart';
import 'package:icc_claro_app/features/routesicc/services/route_service.dart';
import 'package:icc_claro_app/core/utils/helpers/get_roles.dart';
import 'package:provider/provider.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

void showMarkerDetails(
  BuildContext context,
  Map<String, dynamic> location,
  VoidCallback onReload, {
  RouteModel? routeModel,
}) {
  final int? posLocationId = location['posLocationId'];
  print("🔍 showMarkerDetails - posLocationId: $posLocationId");
  print("🔍 showMarkerDetails - location completa: $location");

  if (posLocationId == null) {
    print("Error: posLocationId no encontrado en la ubicación.");
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) => Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 410,
              padding: const EdgeInsets.only(
                  top: 30.0, left: 30.0, right: 30.0, bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "ID: ${location['posLocationId'] ?? "N/A"}\n"
                    "Nombre: ${location['posLocationName'] ?? "N/A"}\n"
                    "Ubicación: ${location['locDescription'] ?? "N/A"}\n"
                    "Tipo de Localidad: ${location['locType'] ?? "N/A"}\n"
                    "Operador: ${location['posOperator'] ?? "N/A"}\n"
                    "Demográficos: ${location['posDemographics'] ?? "N/A"}\n"
                    "Pueblo: ${location['posTown'] ?? "N/A"}\n"
                    "Dirección: ${location['posAddress'] ?? "N/A"}\n"
                    "Zona: ${location['posZone'] ?? "N/A"}\n"
                    "Descripción de Zona: ${location['posZoneDescription'] ?? "N/A"}\n"
                    "Gerente: ${location['manager'] ?? "N/A"}\n"
                    "Asistente: ${location['assistant'] ?? "N/A"}\n"
                    "Canal: ${location['channel'] ?? "N/A"}\n"
                    "Puntuación: ${location['posShareMktValue'] ?? "N/A"}\n"
                    "Código de Agente: ${location['posDealer'] ?? "N/A"}\n"
                    "Código de Localidad: ${location['posLocationCode'] ?? "N/A"}\n",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _navigateTo(
                            context,
                            PosContactsList(
                              posLocationId: posLocationId,
                              location: location,
                              onReload: onReload,
                            ),
                          );
                        },
                        style: _buildButtonStyle(),
                        child: const Column(
                          children: [Text('Ver'), Text('Contactos')],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _navigateTo(
                            context,
                            PosFilesList(
                              posLocationId: posLocationId,
                              location: location,
                              onReload: onReload,
                            ),
                          );
                        },
                        style: _buildButtonStyle(),
                        child: const Column(
                          children: [Text('Ver'), Text('Archivos')],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _showHistorialDialog(context, posLocationId),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                        ),
                        child: const Column(
                          children: [Text('Historial'), Text('de Localidad')],
                        ),
                      ),
                      FutureBuilder<RouteModel?>(
                        future: RouteService().fetchRouteByPosLocationId(
                          context: context,
                          posLocationId: posLocationId,
                        ),
                        builder: (context, snapshot) {
                          print("🔍 marker_details_dialog - FutureBuilder estado: ${snapshot.connectionState}");
                          print("🔍 marker_details_dialog - FutureBuilder data: ${snapshot.data}");
                          print("🔍 marker_details_dialog - FutureBuilder error: ${snapshot.error}");
                          
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                              color: Color(0xFFb60000),
                            );
                          }

                          final matchRoute = snapshot.data;
                          print("🔍 marker_details_dialog - matchRoute: $matchRoute");

                          if (matchRoute == null) {
                            print("🔍 marker_details_dialog - No hay recorrido para posLocationId: $posLocationId");
                            return const SizedBox();
                          }

                          return ElevatedButton(
                            style: _buildButtonStyle(),
                            onPressed: () async {
                              try {
                                final user =
                                    context.read<UserProvider>().getUser();
                                final roles =
                                    getRolesFromAuthorities(user?.authorities);
                                print("🔍 marker_details_dialog - roles: $roles");
                                final updatedRoute = await RouteService()
                                    .fetchRouteById(
                                        matchRoute.posLocationRouteID, context: context);

                                if (!context.mounted) return;

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RouteOptionsScreen(
                                      route: updatedRoute,
                                      roles: roles,
                                      routeType: 'openRoutes',
                                      location: location,
                                      onReload: onReload,
                                    ),
                                  ),
                                );

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Error al cargar recorrido: $e")),
                                );
                              }
                            },
                            child: const Column(
                              children: [
                                Text('Recorrido'),
                                Text('del Punto de Venta'),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

ButtonStyle _buildButtonStyle() {
  return ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: const Color(0xFFb60000),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  );
}

void showReasonDialog(
    BuildContext context, int posLocationId, VoidCallback onReload) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ReasonDialog(
        posLocationId: posLocationId,
        onReload: onReload,
      );
    },
  );
}

void _showHistorialDialog(BuildContext context, int posLocationId) async {
  print('📋 Obteniendo historial para posLocationId: $posLocationId');
  
  try {
    // Usar HttpAuthService para manejar la autenticación correctamente
    final response = await HttpAuthService.authenticatedGet(
      ApiEndpoints.getPosLocAgentHistByLocId,
      queryParameters: {'locId': posLocationId.toString()},
      context: context,
      useCache: true, // Usar caché para historial
    );

    print('📋 Status Code: ${response.statusCode}');
    print('📋 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.only(
                    top: 30.0, left: 30.0, right: 30.0, bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Historial de Localidad',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      child: ListBody(
                        children: data.isEmpty
                            ? [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 150, bottom: 150),
                                    child: const Text(
                                        'No hay records registrados para mostrar.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          decoration: TextDecoration.none,
                                        )),
                                  ),
                                )
                              ]
                            : data.map((item) {
                                return Text(
                                  'Fecha: ${item['creationDate']}\n'
                                  'ID: ${item['locId']}\n'
                                  'Nombre: ${item['locName']}\n'
                                  'Código de Agente: ${item['dealerCode']}\n'
                                  'Fecha de Baja: ${item['unsubscribeDate'] ?? "N/A"}\n'
                                  'Acción: ${item['action']}\n'
                                  'Estado: ${item['locStatus']}\n\n',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    decoration: TextDecoration.none,
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
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
                      child: const Column(
                        children: [
                          Text('Cerrar'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
      print('✅ Historial obtenido exitosamente');
    } else {
      print('❌ Error al cargar los datos: ${response.statusCode}');
      print('   Respuesta del servidor: ${response.body}');
      
      // Mostrar mensaje de error al usuario
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error al cargar el historial: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    print('❌ Excepción al obtener el historial: $e');
    
    // Manejar errores específicos de autenticación
    if (e.toString().contains('Token expirado') || 
        e.toString().contains('No autorizado')) {
      print('🔑 Error de autenticación detectado en historial');
    }
    
    // Mostrar mensaje de error al usuario
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error al cargar el historial: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

void _navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

// Función eliminada - usando get_roles.dart en su lugar

// bool hasAdminPermission(dynamic authorities) {
//   if (authorities == null) return false;

//   try {
//     if (authorities is String) {
//       final decoded = jsonDecode(authorities);
//       if (decoded is Map && decoded.containsKey('message')) {
//         return decoded['message'].contains('POS_ADMIN');
//       }
//     }
//     if (authorities is Map && authorities.containsKey('message')) {
//       return authorities['message'].contains('POS_ADMIN');
//     }
//   } catch (e) {
//     print("Error decoding authorities: $e");
//   }

//   return false;
// }

// void showConfirmationDialog(
//     BuildContext context, int posLocationId, VoidCallback onReload) {
//   final userProvider = Provider.of<UserProvider>(context, listen: false);
//   final user = userProvider.getUser();
//   final userAuthorities = user?.authorities;

//   if (!hasAdminPermission(userAuthorities)) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         backgroundColor: Color(0xFFb60000),
//         content: Text(
//           'No tienes permiso para cerrar este punto de venta.',
//           style: TextStyle(color: Colors.white),
//         ),
//         duration: Duration(seconds: 5),
//       ),
//     );
//     return;
//   }

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Center(
//         child: SingleChildScrollView(
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: 300,
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: const BorderRadius.all(Radius.circular(4)),
//               ),
//               child: Column(
//                 children: [
//                   const Center(
//                     child: Text(
//                       'Confirmar',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     '¿Estás seguro de que quieres cerrar el punto de venta?',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       AlertButton(
//                         text: 'Cancelar',
//                         onPressed: () {
//                           Navigator.of(context).pop();

//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             showMarkerDetails(context,
//                                 {'posLocationId': posLocationId}, onReload);
//                           });
//                         },
//                         color: const Color(0xFFb60000),
//                       ),
//                       AlertButton(
//                         text: 'Confirmar',
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           showReasonDialog(context, posLocationId, onReload);
//                         },
//                         color: const Color(0xFF449D44),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
