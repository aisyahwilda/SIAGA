import 'package:flutter/material.dart';

const _orange = Color(0xFFFB6C00);
const _deepOrange = Color(0xFFE73F1E);
const _paleGold = Color(0xFFFFDD9C);
const _ink = Color(0xFF242321);
const _muted = Color(0xFF77736F);
const _canvas = Color(0xFFFFFFFF);

class _Region {
  const _Region(this.name, this.province);

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
    this.tsunamiPotential,
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
  final String? tsunamiPotential;

  String get formattedMagnitude => magnitude.replaceAll('.', ',');
}

class WilayahScreen extends StatefulWidget {
  const WilayahScreen({super.key});

  @override
  State<WilayahScreen> createState() => _WilayahScreenState();
}

class _WilayahScreenState extends State<WilayahScreen> {
  static const _regions = <_Region>[
    _Region('Balikpapan', 'Kalimantan Timur'),
    _Region('Samarinda', 'Kalimantan Timur'),
    _Region('Bontang', 'Kalimantan Timur'),
    _Region('Sangatta', 'Kalimantan Timur'),
    _Region('Tenggarong', 'Kalimantan Timur'),
    _Region('Penajam', 'Kalimantan Timur'),
    _Region('Tanah Grogot', 'Kalimantan Timur'),
    _Region('Tanjung Redeb', 'Kalimantan Timur'),
    _Region('Sendawar', 'Kalimantan Timur'),
    _Region('Ujoh Bilang', 'Kalimantan Timur'),
  ];

  String? _selectedRegion;

  static const _sampleEarthquakes = <_EarthquakeEvent>[
    _EarthquakeEvent(
      date: '20 Okt 2026',
      time: '11:23 WIB',
      coordinates: '-0.47, 117.15',
      latitude: '0.47° LS',
      longitude: '117.15° BT',
      magnitude: '4.8',
      depth: '12 km',
      region: '10 km Timur Laut Samarinda',
      feltAreas: 'Samarinda, Kutai Kartanegara dan sekitarnya',
      tsunamiPotential: 'Tidak berpotensi',
    ),
    _EarthquakeEvent(
      date: '18 Okt 2026',
      time: '16:42 WIB',
      coordinates: '-0.42, 117.13',
      latitude: '0.42° LS',
      longitude: '117.13° BT',
      magnitude: '3.9',
      depth: '8 km',
      region: '5 km Barat Laut Samarinda',
      feltAreas: 'Samarinda dan sekitarnya',
      tsunamiPotential: 'Tidak berpotensi',
    ),
    _EarthquakeEvent(
      date: '16 Okt 2026',
      time: '09:17 WIB',
      coordinates: '-0.52, 117.18',
      latitude: '0.52° LS',
      longitude: '117.18° BT',
      magnitude: '3.5',
      depth: '10 km',
      region: '15 km Tenggara Samarinda',
      feltAreas: 'Samarinda dan sekitarnya',
      tsunamiPotential: 'Tidak berpotensi',
    ),
    _EarthquakeEvent(
      date: '17 Okt 2026',
      time: '13:08 WITA',
      coordinates: '-1.24, 116.83',
      latitude: '1.24° LS',
      longitude: '116.83° BT',
      magnitude: '3.6',
      depth: '10 km',
      region: '18 km Tenggara Balikpapan',
      feltAreas: 'Balikpapan dan sekitarnya',
      tsunamiPotential: 'Tidak berpotensi',
    ),
    _EarthquakeEvent(
      date: '16 Okt 2026',
      time: '08:21 WITA',
      coordinates: '-1.31, 116.79',
      latitude: '1.31° LS',
      longitude: '116.79° BT',
      magnitude: '3.8',
      depth: '10 km',
      region: '22 km Selatan Balikpapan',
      feltAreas: 'Balikpapan, Penajam dan sekitarnya',
      tsunamiPotential: 'Tidak berpotensi',
    ),
    _EarthquakeEvent(
      date: '15 Okt 2026',
      time: '10:56 WITA',
      coordinates: '-1.08, 116.91',
      latitude: '1.08° LS',
      longitude: '116.91° BT',
      magnitude: '4.3',
      depth: '10 km',
      region: 'Kab. Paser, Kalimantan Timur',
      feltAreas: 'Balikpapan dan sekitarnya',
      tsunamiPotential: 'Tidak berpotensi',
    ),
  ];

  _Region? get _selectedRegionDetails {
    for (final region in _regions) {
      if (region.name == _selectedRegion) return region;
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
                      const SizedBox(height: 10),
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
                            const SizedBox(height: 5),
                            const Text(
                              'Pilih satu kota untuk menjadi wilayah pantauan.',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
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
                        child: filteredRegions.isEmpty
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
                                          const SizedBox(width: 13),
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
                                                const SizedBox(height: 3),
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
                        child: SizedBox(
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
    setState(() => _selectedRegion = result);
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
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.of(context).padding.top + 22,
        22,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wilayah Pantauan',
            style: TextStyle(
              color: _ink,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          if (_selectedRegion == null) ...[
            const SizedBox(height: 7),
            const Text(
              'Pantau informasi gempa di wilayah pilihanmu.',
              style: TextStyle(color: _muted, fontSize: 14, height: 1.45),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEmptyIllustration(),
        const SizedBox(height: 20),
        const Text(
          'Belum Ada Wilayah Pantauan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih wilayah untuk melihat informasi gempa yang relevan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 22),
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
    return SizedBox(
      width: 220,
      height: 165,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 210,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E9),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(
            bottom: 3,
            child: Icon(
              Icons.map_outlined,
              size: 174,
              color: _orange.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: 3,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8D4),
                shape: BoxShape.circle,
                border: Border.all(color: _paleGold, width: 3),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: _orange,
                size: 44,
              ),
            ),
          ),
          Positioned(
            top: 13,
            right: 47,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: _paleGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: _orange, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRegion(_Region region) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionCard(region),
        const SizedBox(height: 23),
        if (_hasSampleEarthquake(region)) ...[
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
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 16),
          _buildEarthquakeResults(region),
        ] else
          _buildNoEventState(region),
      ],
    );
  }

  bool _hasSampleEarthquake(_Region region) {
    return _sampleEarthquakes.any(
      (event) =>
          event.feltAreas.toLowerCase().contains(region.name.toLowerCase()),
    );
  }

  Widget _buildEarthquakeResults(_Region region) {
    final events = _sampleEarthquakes
        .where(
          (event) =>
              event.feltAreas.toLowerCase().contains(region.name.toLowerCase()),
        )
        .toList(growable: false);
    if (events.isEmpty) {
      return _buildNoEventState(region);
    }

    return Column(
      children: [
        for (var index = 0; index < events.length; index++) ...[
          _buildFeltEarthquakeCard(events[index]),
          if (index < events.length - 1) const SizedBox(height: 11),
        ],
      ],
    );
  }

  Widget _buildNoEventState(_Region region) {
    return Column(
      children: [
        const SizedBox(height: 30),
        SizedBox(
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
        const SizedBox(height: 14),
        const Text(
          'Belum ada kejadian yang cocok',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Belum ada kejadian gempa yang dirasakan di wilayah ${region.name}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EE),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFE4CC)),
          ),
          child: const Row(
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
              SizedBox(width: 10),
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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'M ${event.formattedMagnitude}',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.region,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${event.date} • ${event.time}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              const SizedBox(width: 5),
              const Padding(
                padding: EdgeInsets.only(top: 9),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF77736F),
                  size: 21,
                ),
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
                      const SizedBox(width: 11),
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
                            const SizedBox(height: 3),
                            Text(
                              region.name,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 3),
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
    return SizedBox(
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
              padding: const EdgeInsets.fromLTRB(20, 21, 20, 0),
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
                  if (event.tsunamiPotential case final potential?)
                    _detailLine(
                      Icons.tsunami_rounded,
                      'Potensi Tsunami',
                      potential,
                    ),
                  _detailLine(
                    Icons.sensors_rounded,
                    'Dirasakan',
                    event.feltAreas,
                  ),
                  const SizedBox(height: 2),
                  _buildCoordinateIllustration(),
                  const SizedBox(height: 17),
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
      height: 286,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 226,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/ilustrasi.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: _ink),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Detail Gempa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Color(0x66000000), blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFE2CB)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF452B1B).withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_deepOrange, _orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.white,
                      size: 26,
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
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.region,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.date} • ${event.time}',
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5C8),
                      borderRadius: BorderRadius.circular(9),
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE4CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: _orange, size: 18),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Lokasi Pusat Gempa',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              height: 132,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: _CoordinatePatternPainter()),
                  ),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    color: _deepOrange,
                    size: 38,
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 9),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: _orange, size: 16),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Penanda ini hanya ilustrasi area. Titik koordinat di atas adalah acuan lokasi yang lebih tepat.',
                  style: TextStyle(
                    color: Color(0xFF805638),
                    fontSize: 10,
                    height: 1.4,
                  ),
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Icon(icon, color: const Color(0xFFB94B20), size: 20),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
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
