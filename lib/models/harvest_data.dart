class HarvestDataPoint {
  final int year;
  final double quantity; // in Kg

  HarvestDataPoint({required this.year, required this.quantity});
}

class PastHarvestData {
  final List<HarvestDataPoint> dataPoints;

  PastHarvestData({required this.dataPoints});
}

// Paddy types in Sinhala
class PaddyType {
  final String sinhalaName;
  final String englishName;

  const PaddyType({required this.sinhalaName, required this.englishName});
}

class PaddyTypes {
  static const List<PaddyType> types = [
    PaddyType(sinhalaName: 'සම්බා', englishName: 'Samba'),
    PaddyType(sinhalaName: 'කීරි සම්බා', englishName: 'Keeri Samba'),
    PaddyType(sinhalaName: 'සුවඳැල්', englishName: 'Suwandel'),
    PaddyType(sinhalaName: 'නාදු', englishName: 'Nadu'),
    PaddyType(sinhalaName: 'රත්තල්', englishName: 'Raththal'),
  ];
}
