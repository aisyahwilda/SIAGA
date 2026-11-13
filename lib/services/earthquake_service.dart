import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/earthquake.dart';

class EarthquakeService {
  const EarthquakeService({this._client});

  static final _endpoint = Uri.parse(
    'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json',
  );

  final http.Client? _client;

  Future<Earthquake> fetchLatest() async {
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

    final earthquake = info['gempa'];
    if (earthquake is! Map<String, dynamic>) {
      throw const FormatException(
        'Detail gempa tidak ditemukan dalam respons.',
      );
    }

    return Earthquake.fromJson(earthquake);
  }
}
