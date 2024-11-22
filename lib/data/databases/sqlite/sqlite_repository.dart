// ignore_for_file: override_on_non_overriding_member, avoid_print, implementation_imports

import 'package:flutter_map/src/layer/marker_layer.dart';
import 'package:icc_maps/data/databases/db_repository.dart';
import 'package:icc_maps/data/databases/sqlite/dao/antennas_dao.dart';
import 'package:icc_maps/data/databases/sqlite/dao/coverages_dao.dart';
import 'package:icc_maps/data/databases/sqlite/dao/sales_dao.dart';
import 'package:icc_maps/data/entities/antenna_entity.dart';
import 'package:icc_maps/data/entities/coverage_entity.dart';
import 'package:icc_maps/data/entities/marker_entity.dart';
import 'package:icc_maps/data/entities/sale_entity.dart';
import 'package:icc_maps/data/utils/hex_color.dart';

class SqliteRepository extends DbRepository {
  AntennasDAO antennasDAO = AntennasDAO();
  CoveragesDAO coveragesDAO = CoveragesDAO();
  SalesDAO salesDAO = SalesDAO();

  @override
  Future<bool> deleteAntennas(List<int> icBaseCoordsIds) async {
    final results =
        icBaseCoordsIds.map((id) async => await antennasDAO.deleteAntenna(id));
    print("****** DELETE RESULTS -> $results");
    return false;
  }

  @override
  Future<List<Marker>> getAntennas(int polygonTypeId) async {
    final List<AntennaEntity> antennas =
        await antennasDAO.getAntennas(polygonTypeId);
    return antennas
        .map((ant) => MarkerEntity.toMarker(
              polygonTypeId: ant.polygonTypeId,
              lat: ant.coordLat,
              lon: ant.coordLon,
              siteName: ant.siteName,
              siteId: ant.siteId,
            ))
        .toList();
  }

  @override
  Future<bool> insertAntennas(List<AntennaEntity> antennas) async {
    final results =
        antennas.map((ant) async => await antennasDAO.insertAntenna(ant));
    print("****** INSERT RESULTS -> $results");
    return false;
  }

  @override
  Future<bool> updateAntennas(List<AntennaEntity> antennas) async {
    final results =
        antennas.map((ant) async => await antennasDAO.updateAntenna(ant));
    print("****** UPDATE RESULTS -> $results");
    return false;
  }

  @override
  Future<bool> deleteCoverage(int polygonTypeId) async {
    final result = await coveragesDAO.deleteCoverage(polygonTypeId);
    print("****** DELETE RESULTS -> $result");
    return false;
  }

  @override
  Future<Map<String, dynamic>> getCoverage(int polygonTypeId) async {
    final CoverageEntity coverage =
        await coveragesDAO.getCoverage(polygonTypeId);
    if (coverage.isEmpty)
      return {};
    else
      return {
        "color": HexColor(coverage.polygonColor),
        "url": Uri.parse(coverage.polygonURL)
      };
  }

  @override
  Future<bool> insertCoverage(CoverageEntity coverage) async {
    final result = await coveragesDAO.insertCoverage(coverage);
    print("****** INSERT RESULTS -> $result");
    return false;
  }

  @override
  Future<bool> updateCoverage(CoverageEntity coverage) async {
    final result = await coveragesDAO.updateCoverage(coverage);
    print("****** UPDATE RESULTS -> $result");
    return false;
  }

  @override
  Future<bool> deleteSales(List<int> posLocationId) async {
    final results =
        posLocationId.map((id) async => await salesDAO.deleteSale(id));
    print("****** DELETE RESULTS -> $results");
    return false;
  }

  @override
  Future<List<Marker>> getSales(int posLocationId) async {
    final List<SaleEntity> location = await salesDAO.getSales(posLocationId);
    return location
        .map((loc) => MarkerEntity.toSale(
              posLocationId: loc.posLocationId,
              latitude: loc.latitude,
              longitude: loc.longitude,
              posLocationName: loc.posLocationName,
              locType: loc.locType,
              locDescription: loc.locDescription,
              posLocationCode: loc.posLocationCode,
              posOperator: loc.posOperator,
              posDemographics: loc.posDemographics,
              posTown: loc.posTown,
              posAddress: loc.posAddress,
              posZone: loc.posZone,
              posZoneDescription: loc.posZoneDescription,
              posManager: loc.posManager,
              posAssistant: loc.posAssistant,
              channel: loc.channel,
              posShareMktValue: loc.posShareMktValue,
              posDealer: loc.posDealer,
              iconSource: loc.posIcon?.iconSource,
              iconFillColor: loc.posIcon!.iconFillColor,
              iconStrokeColor: loc.posIcon!.iconStrokeColor,
              iconViewBox: '',
              onReload: () {},
            ))
        .toList();
  }

  @override
  Future<bool> insertSales(List<SaleEntity> location) async {
    final results = location.map((loc) async => await salesDAO.insertSale(loc));
    print("****** INSERT RESULTS -> $results");
    return false;
  }

  @override
  Future<bool> updateSales(List<SaleEntity> location) async {
    final results = location.map((loc) async => await salesDAO.updateSale(loc));
    print("****** UPDATE RESULTS -> $results");
    return false;
  }
}
