
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/earthquake.dart';

class StrongEarthquakeService {
  const StrongEarthquakeService({this.client});

  static final Uri _endpoint = Uri.parse(
    'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json',
  );

  final http.Client? client;

  Future<List<Earthquake>> fetchStrongEarthquakes() async {
    final response = await (client?.get(_endpoint) ?? http.get(_endpoint))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw http.ClientException(
        'BMKG mengembalikan status HTTP ${response.statusCode}.',
        _endpoint,
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format respons BMKG tidak valid.');
    }

    final info = decoded['Infogempa'];

    if (info is! Map<String, dynamic>) {
      throw const FormatException('Data gempa BMKG tidak ditemukan.');
    }

    final earthquakes = info['gempa'];

    if (earthquakes is! List) {
      throw const FormatException('Daftar gempa BMKG tidak valid.');
    }

    return earthquakes
        .whereType<Map<String, dynamic>>()
        .map(Earthquake.fromJson)
        .toList(growable: false);
  }
}
