import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/earthquake.dart';
import '../models/felt_earthquake.dart';
import '../services/felt_earthquake_service.dart';
import '../services/strong_earthquake_service.dart';
import '../services/wilayah_service.dart';

const _orange = Color(0xFFFB6C00);
const _deepOrange = Color(0xFFE73F1E);
const _ink = Color(0xFF242321);
const _muted = Color(0xFF77736F);
const _canvas = Color(0xFFFFFFFF);


class _Region {
  const _Region({
    required this.id,
    required this.name,
    required this.province,
  });

  final String id;
  final String name;
  final String province;
}

class _EarthquakeEvent {
  const _EarthquakeEvent({
    required this.date,
    required this.time,
    required this.coordinates,
    required this.latitude,
    required this.longitude,
    required this.magnitude,
    required this.depth,
    required this.region,
    required this.feltAreas,
  });

  final String date;
  final String time;
  final String coordinates;
  final String latitude;
  final String longitude;
  final String magnitude;
  final String depth;
  final String region;
  final String feltAreas;

  String get formattedMagnitude => magnitude.replaceAll('.', ',');
}

class WilayahScreen extends StatefulWidget {
  const WilayahScreen({super.key});

  @override
  State<WilayahScreen> createState() => _WilayahScreenState();
}

class _WilayahScreenState extends State<WilayahScreen> {
  final WilayahService _wilayahService = WilayahService();

  final FeltEarthquakeService _feltEarthquakeService =
      const FeltEarthquakeService();
  
  final StrongEarthquakeService _strongEarthquakeService =
    const StrongEarthquakeService();

  late Future<List<Earthquake>> _strongEarthquakesFuture;

  List<_Region> _regions = [];

  bool _isLoadingRegions = false;
  String? _regionError;

  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedRegionId;

  late Future<List<FeltEarthquake>> _feltEarthquakesFuture;

  Future<void> _loadRegions() async {
  setState(() {
    _isLoadingRegions = true;
    _regionError = null;
  });

  try {
    final data = await _wilayahService.getAllRegencies();

    if (!mounted) return;

    setState(() {
      _regions = data.map((item) {
        return _Region(
          id: item.id,
          name: item.name,
          province: item.provinceName,
        );
      }).toList();

      _isLoadingRegions = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _regionError = e.toString();
      _isLoadingRegions = false;
    });
  }
}

  @override
  void initState() {
    super.initState();

    _feltEarthquakesFuture =
        _feltEarthquakeService.fetchFeltEarthquakes();

    _strongEarthquakesFuture =
        _strongEarthquakeService.fetchStrongEarthquakes();

    _loadRegions();
    _loadSavedRegion();
  }

  Future<void> _loadSavedRegion() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final row = await supabase
          .from('wilayah_pantauan')
          .select('nama_wilayah, nama_provinsi')
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted || row == null) return;
      setState(() {
        _selectedRegion = row['nama_wilayah'] as String?;
        _selectedProvince = row['nama_provinsi'] as String?;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat wilayah tersimpan: $error')),
      );
    }
  }

  Future<void> _saveSelectedRegion(_Region region) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    try {
      await supabase.from('wilayah_pantauan').upsert(
        {
          'user_id': user.id,
          'nama_wilayah': region.name,
          'nama_provinsi': region.province,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id',
      );

      if (!mounted) return;
      setState(() {
        _selectedRegion = region.name;
        _selectedProvince = region.province;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wilayah pantauan berhasil disimpan.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan wilayah: $error')),
      );
    }
  }

  void _retryFeltEarthquakesRequest() {
    setState(() {
      _feltEarthquakesFuture =
          _feltEarthquakeService.fetchFeltEarthquakes();
    });
  }

_Region? get _selectedRegionDetails {
  for (final region in _regions) {
    if (region.name == _selectedRegion &&
        region.province == _selectedProvince) {
      return region;
    }
  }

  if (_selectedRegion != null && _selectedProvince != null) {
    return _Region(
      id: _selectedRegionId ?? '',
      name: _selectedRegion!,
      province: _selectedProvince!,
    );
  }

  return null;
}

  Future<void> _openRegionPicker() async {
    var query = '';
    var draftSelection = _selectedRegion;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredRegions = _regions.where((region) {
              final searchText = '${region.name} ${region.province}'
                  .toLowerCase();
              return searchText.contains(query.trim().toLowerCase());
            }).toList();

            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: const BoxDecoration(
                  color: _canvas,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(height: 10),
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7E2DC),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Wilayah',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(height: 5),
                            const Text(
                              'Pilih satu kota untuk menjadi wilayah pantauan.',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            Container(height: 18),
                            TextField(
                              onChanged: (value) =>
                                  setSheetState(() => query = value),
                              decoration: InputDecoration(
                                hintText: 'Cari kota atau provinsi',
                                hintStyle: const TextStyle(color: _muted),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: _muted,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F3F0),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _isLoadingRegions
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: _orange,
                                ),
                              )
                            : _regionError != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.cloud_off_outlined,
                                            color: _orange,
                                            size: 35,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Gagal memuat daftar wilayah.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: _muted),
                                          ),
                                          const SizedBox(height: 10),
                                          TextButton(
                                            onPressed: () {
                                              _loadRegions();
                                            },
                                            child: const Text(
                                              'Coba lagi',
                                              style: TextStyle(color: _orange),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : filteredRegions.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Wilayah tidak ditemukan',
                                          style: TextStyle(color: _muted),
                                        ),
                                      )
                                    : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  0,
                                  22,
                                  12,
                                ),
                                itemCount: filteredRegions.length,
                                separatorBuilder: (_, index) => const Divider(
                                  height: 1,
                                  indent: 54,
                                  color: Color(0xFFF0ECE7),
                                ),
                                itemBuilder: (context, index) {
                                  final region = filteredRegions[index];
                                  final isSelected =
                                      draftSelection == region.name;
                                  return InkWell(
                                    onTap: () => setSheetState(
                                      () => draftSelection = region.name,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF1E6),
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            child: const Icon(
                                              Icons.location_on_outlined,
                                              color: _orange,
                                              size: 21,
                                            ),
                                          ),
                                          Container(width: 13),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  region.name,
                                                  style: const TextStyle(
                                                    color: _ink,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(height: 3),
                                                Text(
                                                  region.province,
                                                  style: const TextStyle(
                                                    color: _muted,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? _orange
                                                    : const Color(0xFFC9C4BE),
                                                width: isSelected ? 6 : 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Color(0xFFF0ECE7)),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: draftSelection == null
                                ? null
                                : () =>
                                      Navigator.of(sheetContext)
                                          .pop(draftSelection),
                            style: FilledButton.styleFrom(
                              backgroundColor: _orange,
                              disabledBackgroundColor: const Color(0xFFE8E4DF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Simpan Pilihan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    final selected = _regions.firstWhere(
      (region) => region.name == result,
    );
    await _saveSelectedRegion(selected);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _canvas,
      child: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_selectedRegionDetails case final region?)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 128),
                sliver: SliverToBoxAdapter(child: _buildSelectedRegion(region)),
              )
            else
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                  child: Center(child: _buildEmptyState()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    return Container(
      color: _canvas,
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.of(context).padding.top + 20,
        22,
        18,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _deepOrange,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wilayah Pantauan',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
                if (_selectedRegion == null) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'Pantau informasi gempa di wilayah pilihanmu.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEmptyIllustration(),
        Container(height: 20),
        const Text(
          'Belum Ada Wilayah Pantauan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(height: 8),
        const Text(
          'Pilih wilayah untuk melihat informasi gempa yang relevan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
        ),
        Container(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 270),
          child: _primaryButton(
            label: 'Pilih Wilayah',
            icon: Icons.add_location_alt_outlined,
            onPressed: _openRegionPicker,
          ),
        ),
      ],
    );
  }

  

  Widget _buildEmptyIllustration() {
    return const SizedBox(
      width: 220,
      height: 165,
      child: Center(
        child: Icon(
          Icons.location_off_outlined,
          size: 130,
          color: Color(0xFFFFC18F),
        ),
      ),
    );
  }


  Widget _buildSelectedRegion(_Region region) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionCard(region),
        const SizedBox(height: 23),
        FutureBuilder<List<FeltEarthquake>>(
          future: _feltEarthquakesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final allEvents = snapshot.data ?? const <FeltEarthquake>[];
            final events = _eventsFor(region, allEvents);

            if (events.isEmpty) {
              return _buildNoEventState(region);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gempa Dirasakan',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Kejadian gempa yang dirasakan di wilayah ${region.name} berdasarkan data BMKG.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEarthquakeResults(events),
                const SizedBox(height: 12),
                const Text(
                  'Sumber: BMKG',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        _buildStrongEarthquakeSection(),
      ],
    );
  }


  Widget _buildStrongEarthquakeSection() {
    return FutureBuilder<List<Earthquake>>(
      future: _strongEarthquakesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _orange),
            ),
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gempa Magnitudo 5,0+',
                style: TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Data gempa gagal dimuat.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _strongEarthquakesFuture =
                        _strongEarthquakeService.fetchStrongEarthquakes();
                  });
                },
                child: const Text(
                  'Coba lagi',
                  style: TextStyle(color: _orange),
                ),
              ),
            ],
          );
        }

        final earthquakes = (snapshot.data ?? [])
            .where((earthquake) {
              final magnitude = double.tryParse(
                earthquake.magnitude.replaceAll(',', '.'),
              );

              return magnitude != null && magnitude >= 5.0;
            })
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gempa Magnitudo 5,0+',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Daftar 15 kejadian gempa magnitudo 5,0 atau lebih berdasarkan data BMKG.',
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            if (earthquakes.isEmpty)
              const Text(
                'Belum ada data gempa.',
                style: TextStyle(color: _muted, fontSize: 13),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: earthquakes.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(height: 11),
                itemBuilder: (context, index) {
                  final earthquake = earthquakes[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF0ECE8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF0D3),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'M${earthquake.formattedMagnitude}',
                            style: const TextStyle(
                              color: _deepOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                earthquake.region,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${earthquake.date} • ${earthquake.time}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kedalaman: ${earthquake.depth}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),
            const Text(
              'Sumber: BMKG',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        );
      },
    );
  }

String _normalizeRegionName(String value) {
  return value
      .toLowerCase()
      .replaceAll(
        RegExp(r'\b(kabupaten|kab\.?|kota)\b'),
        ' ',
      )
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

  List<_EarthquakeEvent> _eventsFor(
    _Region region,
    List<FeltEarthquake> allEvents,
  ) {
    final selectedName = _normalizeRegionName(region.name);

    return allEvents
        .where((event) {
          final feltText = _normalizeRegionName(event.feltAreas);

        return RegExp(
          r'(^| )' + RegExp.escape(selectedName) + r'( |$)',
        ).hasMatch(feltText); 
        })
        .map(
          (event) => _EarthquakeEvent(
            date: event.date,
            time: event.time,
            coordinates: event.coordinates ?? '-',
            latitude: event.latitude ?? '-',
            longitude: event.longitude ?? '-',
            magnitude: event.magnitude,
            depth: event.depth ?? '-',
            region: event.region,
            feltAreas: event.feltAreas,
          ),
        )
        .toList(growable: false);
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0ECE8)),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _orange,
            ),
          ),
          SizedBox(height: 13),
          Text(
            'Memuat data gempa dari BMKG...',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0ECE8)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: _orange,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Data gempa gagal dimuat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _retryFeltEarthquakesRequest,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                color: _orange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarthquakeResults(List<_EarthquakeEvent> events) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, index) => Container(height: 11),
      itemBuilder: (context, index) {
        return _buildFeltEarthquakeCard(events[index]);
      },
    );
  }

  Widget _buildNoEventState(_Region region) {
    return Column(
      children: [
        Container(height: 30),
        Container(
          height: 108,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.manage_search_rounded,
                size: 72,
                color: Color(0xFF9CA3AF),
              ),
              Positioned(
                right: 82,
                bottom: 12,
                child: Icon(
                  Icons.search_rounded,
                  size: 28,
                  color: _orange.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Container(height: 14),
        const Text(
          'Belum ada kejadian yang cocok',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(height: 7),
        Text(
          'Belum ada kejadian gempa yang dirasakan di wilayah ${region.name}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        Container(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EE),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFE4CC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFFB6C00),
                  size: 19,
                ),
              ),
              Container(width: 10),
              Expanded(
                child: Text(
                  'Kejadian yang dirasakan dapat berbeda dari lokasi pusat gempa. Informasi gempa dapat berubah sewaktu-waktu.',
                  style: TextStyle(
                    color: Color(0xFF805638),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeltEarthquakeCard(_EarthquakeEvent event) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _EarthquakeDetailScreen(event: event),
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0ECE8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C2118).withValues(alpha: 0.045),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF0D3), Color(0xFFFFD287)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'M${event.formattedMagnitude}',
                  style: const TextStyle(
                    color: _deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M ${event.formattedMagnitude}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(height: 4),
                    Text(
                      event.region,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    Container(height: 3),
                    Text(
                      '${event.date} • ${event.time}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    Container(height: 4),
                    Text(
                      'Dirasakan: ${event.feltAreas}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF77736F),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionCard(_Region region) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7EF), Color(0xFFFFE8D3)],
          ),
          border: Border.all(color: const Color(0xFFFFE1C7)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _deepOrange.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/kota.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: _orange,
                          size: 27,
                        ),
                      ),
                      Container(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wilayah yang dipantau',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(height: 3),
                            Text(
                              region.name,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            Container(height: 3),
                            Text(
                              region.province,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _openRegionPicker,
                      icon: const Icon(Icons.edit_rounded, size: 15),
                      label: const Text('Ganti Wilayah'),
                      style: TextButton.styleFrom(
                        foregroundColor: _deepOrange,
                        backgroundColor: Colors.white.withValues(alpha: 0.94),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _EarthquakeDetailScreen extends StatelessWidget {
  const _EarthquakeDetailScreen({required this.event});

  final _EarthquakeEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                children: [
                  _detailLine(
                    Icons.vertical_align_bottom_rounded,
                    'Kedalaman',
                    event.depth,
                  ),
                  _detailLine(
                    Icons.location_on_outlined,
                    'Koordinat',
                    '${event.latitude}, ${event.longitude}',
                  ),
                  _detailLine(
                    Icons.sensors_rounded,
                    'Dirasakan',
                    event.feltAreas,
                  ),
                  Container(height: 2),
                  _buildCoordinateIllustration(),
                  Container(height: 17),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sumber: BMKG',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 224,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 172,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF1E6), Color(0xFFFFE2CC)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Kembali',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded, color: _ink),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Detail Gempa',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.monitor_heart_outlined,
                          size: 32,
                          color: _orange.withValues(alpha: 0.22),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF4E8DF)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39291F).withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'M ${event.formattedMagnitude}',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          event.region,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${event.date} • ${event.time}',
                          style: const TextStyle(color: _muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Dirasakan',
                      style: TextStyle(
                        color: _deepOrange,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateIllustration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1E7DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: _orange, size: 19),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lokasi Pusat Gempa',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 150,
              width: double.infinity,
              color: const Color(0xFFFFF3E9),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _orange.withValues(alpha: 0.10),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _orange.withValues(alpha: 0.14),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.09),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: _deepOrange,
                      size: 32,
                    ),
                  ),
                  Positioned(
                    right: 9,
                    bottom: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${event.latitude}, ${event.longitude}',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _muted, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ilustrasi lokasi. Gunakan koordinat sebagai acuan posisi.',
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            child: Icon(icon, color: const Color(0xFFB94B20), size: 20),
          ),
          Container(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinatePatternPainter extends CustomPainter {
  const _CoordinatePatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFFFEEDF), BlendMode.src);
    final landPaint = Paint()
      ..color = const Color(0xFFFFDCC0).withValues(alpha: 0.55);
    final landShapes = [
      Path()
        ..moveTo(0, size.height * .12)
        ..cubicTo(
          size.width * .2,
          size.height * .04,
          size.width * .2,
          size.height * .3,
          size.width * .38,
          size.height * .34,
        )
        ..cubicTo(
          size.width * .5,
          size.height * .38,
          size.width * .34,
          size.height * .72,
          size.width * .49,
          size.height,
        )
        ..lineTo(0, size.height)
        ..close(),
      Path()
        ..moveTo(size.width, size.height * .08)
        ..cubicTo(
          size.width * .78,
          size.height * .12,
          size.width * .85,
          size.height * .34,
          size.width * .65,
          size.height * .45,
        )
        ..cubicTo(
          size.width * .55,
          size.height * .55,
          size.width * .84,
          size.height * .72,
          size.width,
          size.height * .8,
        )
        ..close(),
    ];
    for (final shape in landShapes) {
      canvas.drawPath(shape, landPaint);
    }

    final ringPaint = Paint()
      ..color = const Color(0xFFFB6C00).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width * .5, size.height * .48);
    for (final radius in [20.0, 34.0, 49.0]) {
      canvas.drawCircle(center, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoordinatePatternPainter oldDelegate) => false;
}
