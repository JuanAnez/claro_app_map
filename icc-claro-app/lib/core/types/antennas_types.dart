enum AntennasTypes {
  fwa("FWA", 3),
  t5g("T5G", 16);

  final String key;
  final int polygonTypeId;
  const AntennasTypes(this.key, this.polygonTypeId);
}
