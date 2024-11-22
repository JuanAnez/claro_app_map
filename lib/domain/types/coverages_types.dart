enum CoveragesTypes {
  gpn("GPN", 5), // <- id: 5 = GPON.geojson
  fiveM("VRAD", 11), // <- id: 1 = FWA-5M.geojson
  tenM("FWA", 2), // <- id: 2 = FWA-10M.geojson
  lte("LTE", 7), // <- id: 7 = CLAROLTE.geojson
  threeG("3G", 6); // <- id: 6 = CLARO3G.geojson

  // - Coverages 5G and WRAD, are NOT USED !!
  // - Mapping buttons

  final String key;
  final int id;
  const CoveragesTypes(this.key, this.id);
}
