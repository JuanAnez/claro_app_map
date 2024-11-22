import 'package:icc_maps/data/network/payload/MessageResponse.dart';

abstract class SaleRepository {
  Future<MessageResponse> findSales(int posLocationId);
}
