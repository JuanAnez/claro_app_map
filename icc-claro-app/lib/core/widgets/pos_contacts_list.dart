import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/features/map/presentation/widgets/marker_details_dialog.dart';
import 'package:icc_claro_app/core/config/api_endpoints.dart';
import 'package:icc_claro_app/core/services/http_auth_service.dart';

class PosContactsList extends StatefulWidget {
  final int posLocationId;
  final Map<String, dynamic> location;
  final VoidCallback onReload;
  const PosContactsList({
    super.key,
    required this.posLocationId,
    required this.location,
    required this.onReload,
  });

  @override
  State<PosContactsList> createState() => _PosContactsListState();
}

class _PosContactsListState extends State<PosContactsList> {
  late Future<List<Map<String, dynamic>>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = fetchContacts(widget.posLocationId);
  }

  Future<List<Map<String, dynamic>>> fetchContacts(int posLocationId) async {
    print('👥 Obteniendo contactos para posLocationId: $posLocationId');
    
    try {
      // Usar HttpAuthService para manejar la autenticación correctamente
      final response = await HttpAuthService.authenticatedGet(
        ApiEndpoints.getAllPosContactsByLocation,
        queryParameters: {'posLocation': posLocationId.toString()},
        context: context,
        useCache: true, // Usar caché para contactos
      );

      print('👥 Status Code: ${response.statusCode}');
      print('👥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Contactos obtenidos exitosamente: ${data.length} contactos');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Error al cargar contactos: ${response.statusCode}');
        print('   Respuesta del servidor: ${response.body}');
        throw Exception('Error al cargar contactos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Excepción al obtener contactos: $e');
      
      // Manejar errores específicos de autenticación
      if (e.toString().contains('Token expirado') || 
          e.toString().contains('No autorizado')) {
        print('🔑 Error de autenticación detectado en contactos');
      }
      
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Lista de Contactos',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showMarkerDetails(context, widget.location, widget.onReload);
            });
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingProgress());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final contacts = snapshot.data ?? [];
          if (contacts.isEmpty) {
            return const Center(
              child: Text(
                'No hay contactos para mostrar.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                color: Colors.grey[700],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[900],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    contact['contactName'] ?? 'Sin nombre',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contact['contactEmail'] != null)
                        Text('Email: ${contact['contactEmail']}',
                            style: const TextStyle(color: Colors.white70)),
                      if (contact['contactAddress'] != null)
                        Text('Dirección: ${contact['contactAddress']}',
                            style: const TextStyle(color: Colors.white70)),
                      if (contact['contactPhone1'] != null)
                        Text('Teléfono 1: ${contact['contactPhone1']}',
                            style: const TextStyle(color: Colors.white70)),
                      if (contact['contactPhone2'] != null)
                        Text('Teléfono 2: ${contact['contactPhone2']}',
                            style: const TextStyle(color: Colors.white70)),
                      if (contact['contactPhone3'] != null)
                        Text('Teléfono 3: ${contact['contactPhone3']}',
                            style: const TextStyle(color: Colors.white70)),
                      if (contact['contactType'] != null)
                        Text('Tipo: ${contact['contactType']}',
                            style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
