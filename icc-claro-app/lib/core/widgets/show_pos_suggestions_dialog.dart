// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class PosSuggestionsScreen extends StatefulWidget {
  final String town;
  final String currentLeader;
  final String pointsToLeader;
  final List<dynamic> posTypePredictions;

  const PosSuggestionsScreen({
    super.key,
    required this.town,
    required this.currentLeader,
    required this.pointsToLeader,
    required this.posTypePredictions,
  });

  @override
  _PosSuggestionsScreenState createState() => _PosSuggestionsScreenState();
}

class _PosSuggestionsScreenState extends State<PosSuggestionsScreen> {
  static const double cellWidth = 200.0;
  static const double cellHeight = 52.0;
  late final double tableWidth;
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();

  @override
  void initState() {
    super.initState();
    tableWidth = cellWidth * 6;

    _horizontalBodyController.addListener(() {
      _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
    });
  }

  @override
  void dispose() {
    _horizontalBodyController.dispose();
    _horizontalHeaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sugerencias de POS - ${widget.town}',
            style: const TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: const Color(0xFFC21618),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              controller: _horizontalHeaderController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tableWidth),
                child: Row(
                  children: _buildHeaderCells(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _horizontalBodyController,
              child: SingleChildScrollView(
                controller: _horizontalBodyController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: tableWidth),
                  child: ListView.builder(
                    itemCount: widget.posTypePredictions.length,
                    itemBuilder: (context, index) {
                      final item = widget.posTypePredictions[index];
                      final isEven = index % 2 == 0;
                      return Container(
                        color: isEven ? Colors.white : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            _buildCell(widget.town),
                            _buildCell(widget.currentLeader),
                            _buildCell(widget.pointsToLeader),
                            _buildCell(item['locTypeName']),
                            _buildCell(item['msValue'].toString()),
                            _buildCell(item['count'].toString()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderCells() {
    const headers = [
      'Pueblo',
      'Líder Actual',
      'Puntos \npara Liderar',
      'Tipo de Localidad',
      'Ponderación \nde Localidad',
      'Cantidad de \nLocalidades a Abrir',
    ];
    return headers.map((header) {
      return Container(
        width: cellWidth,
        height: cellHeight,
        padding: const EdgeInsets.all(6.0),
        color: Colors.red,
        child: Text(
          header,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }

  Widget _buildCell(String text) {
    return Container(
      width: cellWidth,
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
