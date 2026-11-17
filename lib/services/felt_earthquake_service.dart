import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/felt_earthquake.dart';

class FeltEarthquakeService {
  const FeltEarthquakeService({this._client});

  final http.Client? _client;

  static final Uri _endpoint = Uri.parse(
    'https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json',
  );

  Future<List<FeltEarthquake>> fetchFeltEarthquakes() async {
    final response = await (_client?.get(_endpoint) ?? http.get(_endpoint))
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
      throw const FormatException('Data gempa tidak ditemukan dalam respons.');
    }

    final earthquakes = info['gempa'];
    if (earthquakes is! List) {
      throw const FormatException('Daftar gempa BMKG tidak valid.');
    }

    return earthquakes.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Format salah satu data gempa tidak valid.');
      }
      return FeltEarthquake.fromJson(item);
    }).toList(growable: false);
  }
}
