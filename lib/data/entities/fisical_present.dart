import 'package:flutter/material.dart';

class FisicalPresent extends StatelessWidget {
  final List<Map<String, String>> marketShareDetailList;
  final String groupName;

  // Definir el mapa de colores para las localidades
  final Map<String, Color> localidadColors = {
    'CLARO': const Color(0xFFFF0000),
    'BOOST': const Color(0xFFFF651D),
    'TMOBILE': const Color(0xFFE10974),
    'LIBERTY': const Color(0xFF4F8DC3),
    'Multimarca': const Color(0xFFFFFF00),
  };

  FisicalPresent({
    Key? key,
    required this.marketShareDetailList,
    required this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (marketShareDetailList.isEmpty)
                const Center(
                  child: Text(
                    'No hay datos de participación en el mercado.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
              else
                Text(
                  groupName,
                  style: const TextStyle(
                    color: Color(0xFFb60000),
                    fontSize: 22,
                    decoration: TextDecoration.none,
                  ),
                ),
              const SizedBox(height: 30),
              for (var detail in marketShareDetailList) ...[
                RichText(
                  text: TextSpan(
                    text: detail['localidad'] ?? 'Desconocida',
                    style: TextStyle(
                      color:
                          localidadColors[detail['localidad']] ?? Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Text(
                  'Participación: ${detail['porcientoParticipacion'] ?? 'N/A'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
                child: const Text('Atrás'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
