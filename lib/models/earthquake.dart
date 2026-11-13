class Earthquake {
  const Earthquake({
    required this.date,
    required this.time,
    required this.magnitude,
    required this.depth,
    required this.region,
    required this.potential,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    return Earthquake(
      date: _readField(json, 'Tanggal'),
      time: _readField(json, 'Jam'),
      magnitude: _readField(json, 'Magnitude'),
      depth: _readField(json, 'Kedalaman'),
      region: _readField(json, 'Wilayah'),
      potential: _readField(json, 'Potensi'),
    );
  }

  final String date;
  final String time;
  final String magnitude;
  final String depth;
  final String region;
  final String potential;

  String get formattedMagnitude => magnitude.replaceAll('.', ',');

  static String _readField(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Data gempa BMKG tidak memiliki field "$key".');
    }
    return value;
  }
}
