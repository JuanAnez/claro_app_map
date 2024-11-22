import 'package:icc_maps/domain/types/antennas_types.dart';
import 'package:icc_maps/domain/types/coverages_types.dart';

abstract class ButtonsActionType {}

class CollapseButtons extends ButtonsActionType {}

class ChangeMapDisplay extends ButtonsActionType {}

class ZoomMap extends ButtonsActionType {
  final bool zoomIn;
  ZoomMap({required this.zoomIn});
}

class ShowAntennas extends ButtonsActionType {
  final AntennasTypes antennaType;
  ShowAntennas(this.antennaType);
}

class ShowCoverages extends ButtonsActionType {
  final CoveragesTypes coverageType;
  ShowCoverages(this.coverageType);
}
