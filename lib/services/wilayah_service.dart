
import 'dart:convert';
import 'package:http/http.dart' as http;

class WilayahIndonesia {
  final String id;
  final String name;
  final String provinceId;
  final String provinceName;

  const WilayahIndonesia({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.provinceName,
  });
}

class WilayahService {
  static const String _baseUrl =
      'https://www.emsifa.com/api-wilayah-indonesia/v2';

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/provinces.json'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil daftar provinsi.');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] as List;

    return data.cast<Map<String, dynamic>>();
  }

  Future<List<WilayahIndonesia>> getAllRegencies() async {
  final provinces = await getProvinces();

  final requests = provinces.map((province) async {
    final provinceId = province['id'].toString();
    final provinceName = province['name'].toString();

    final response = await http
        .get(Uri.parse('$_baseUrl/regencies/$provinceId.json'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil wilayah $provinceName.');
    }

    final decoded = jsonDecode(response.body);
    final regencies = decoded['data'] as List;

    return regencies.map((item) {
      return WilayahIndonesia(
        id: item['id'].toString(),
        name: item['name'].toString(),
        provinceId: provinceId,
        provinceName: provinceName,
      );
    }).toList();
  });

  final results = await Future.wait(requests);

  return results.expand((items) => items).toList();
 }
}