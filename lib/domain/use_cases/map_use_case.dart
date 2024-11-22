import 'package:flutter_map/flutter_map.dart';
import 'package:icc_maps/data/entities/sale_entity.dart';
import 'package:icc_maps/data/services/map_service.dart';
import 'package:icc_maps/data/services/sale_service.dart';
import 'package:icc_maps/domain/types/antennas_types.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';

class MapUseCase {
  MapService mapService = MapService();
  SaleService saleService = SaleService();

  Future<List<Marker>> getAntennas(AntennasTypes type) async =>
      await mapService.findAntennas(type.polygonTypeId);

  Future<List<Polygon>> getCoverage(CoveragesTypes type) async =>
      await mapService.findCoverages(type.id);

  Future<List<Marker>> getSales(SaleEntity type) async =>
      await saleService.findSales(type.posLocationId);
}
