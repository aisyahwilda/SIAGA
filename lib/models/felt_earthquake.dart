class FeltEarthquake {
  const FeltEarthquake({
    required this.date,
    required this.time,
    required this.magnitude,
    required this.region,
    required this.feltAreas,
    this.coordinates,
    this.latitude,
    this.longitude,
    this.depth,
  });

  factory FeltEarthquake.fromJson(Map<String, dynamic> json) {
    return FeltEarthquake(
      date: _readRequiredField(json, 'Tanggal'),
      time: _readRequiredField(json, 'Jam'),
      magnitude: _readRequiredField(json, 'Magnitude'),
      region: _readRequiredField(json, 'Wilayah'),
      feltAreas: _readRequiredField(json, 'Dirasakan'),
      coordinates: _readOptionalField(json, 'Coordinates'),
      latitude: _readOptionalField(json, 'Lintang'),
      longitude: _readOptionalField(json, 'Bujur'),
      depth: _readOptionalField(json, 'Kedalaman'),
    );
  }

  final String date;
  final String time;
  final String magnitude;
  final String region;
  final String feltAreas;
  final String? coordinates;
  final String? latitude;
  final String? longitude;
  final String? depth;

  static String _readRequiredField(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Data gempa BMKG tidak memiliki field "$key".');
    }
    return value.trim();
  }

  static String? _readOptionalField(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
