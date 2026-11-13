import 'package:flutter/material.dart';

import '../models/earthquake.dart';
import '../services/earthquake_service.dart';

class SiagaHomePage extends StatefulWidget {
  const SiagaHomePage({
    super.key,
    required this.onOpenWilayah,
    required this.onOpenPenilaian,
    this.earthquakeService = const EarthquakeService(),
  });

  final VoidCallback onOpenWilayah;
  final VoidCallback onOpenPenilaian;
  final EarthquakeService earthquakeService;

  @override
  State<SiagaHomePage> createState() => _SiagaHomePageState();
}

class _SiagaHomePageState extends State<SiagaHomePage> {
  late Future<Earthquake> _earthquakeFuture;

  @override
  void initState() {
    super.initState();
    _earthquakeFuture = widget.earthquakeService.fetchLatest();
  }

  void _retryEarthquakeRequest() {
    setState(() {
      _earthquakeFuture = widget.earthquakeService.fetchLatest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tinggi = MediaQuery.of(context).size.height;
    final lebar = MediaQuery.of(context).size.width;
    final statusBar = MediaQuery.of(context).padding.top;
    final y = tinggi * 0.1;
    final pad = lebar * 0.06;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(statusBar: statusBar, y: y, pad: pad),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: y * 0.15),
                _buildLocationSelector(y: y),
                Container(height: y * 0.25),
                _buildMainEarthquakeCard(),
                Container(height: y * 0.25),
                _buildFeltSection(),
                Container(height: 18),
                _buildEvaluationBanner(),
                Container(height: y * 1.2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection({
    required double statusBar,
    required double y,
    required double pad,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(pad, statusBar + 12, pad, y * 0.22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE4D7), Color(0xFFFFF5EF), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/siaga_icon.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
              Container(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIAGA',
                      style: TextStyle(
                        color: Color(0xFFE95727),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        height: 1.1,
                      ),
                    ),
                    Container(height: 3),
                    Text(
                      'Sistem Informasi Gempa',
                      style: TextStyle(color: Color(0xFF514740), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(height: y * 0.35),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, Aisyah',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              Container(height: 6),
              Text(
                'Semoga selalu dalam keadaan aman dan siap.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF77736F),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector({required double y}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: widget.onOpenWilayah,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: y * 0.16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF553923).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Color(0xFFE95727),
                size: 29,
              ),
              Container(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wilayah Pantauan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF89837E)),
                    ),
                    Container(height: 3),
                    Text(
                      'Balikpapan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF252321),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF77736F)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainEarthquakeCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final artworkWidth = constraints.maxWidth * 0.37;
        final artworkHeight = constraints.maxWidth < 310 ? 112.0 : 142.0;
        final magnitudeSize = constraints.maxWidth < 310 ? 42.0 : 50.0;

        return FutureBuilder<Earthquake>(
          future: _earthquakeFuture,
          builder: (context, snapshot) {
            final earthquake = snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE73F1E), Color(0xFFFB6C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE73F1E).withValues(alpha: 0.24),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _LatestEarthquakeLabel(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (snapshot.hasError)
                            IconButton(
                              onPressed: _retryEarthquakeRequest,
                              tooltip: 'Coba lagi',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          const _SourceBadge(),
                        ],
                      ),
                    ],
                  ),
                  Container(height: 17),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MagnitudeText(
                              fontSize: magnitudeSize,
                              magnitude: earthquake?.formattedMagnitude ?? '—',
                            ),
                            Container(height: 12),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                            Container(height: 11),
                            _LatestEarthquakeDetails(
                              earthquake: earthquake,
                              isLoading: isLoading,
                              hasError: snapshot.hasError,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 12),
                      _buildEarthquakeArtwork(
                        width: artworkWidth,
                        height: artworkHeight,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEarthquakeArtwork({
    required double width,
    required double height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        height: height,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9B637), Color(0xFFFB6C00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomPaint(painter: _KotaPainter()),
        ),
      ),
    );
  }

  Widget _buildFeltSection() {
    const events = [
      (
        magnitude: 'M 4,8',
        location: 'Laut Sulawesi',
        time: '28 Sep 2026 • 10:42 WITA',
        feltArea: 'Balikpapan dan sekitarnya',
      ),
      (
        magnitude: 'M 3,6',
        location: 'Paser, Kalimantan Timur',
        time: '28 Sep 2026 • 08:15 WITA',
        feltArea: 'Paser dan Tanah Grogot',
      ),
      (
        magnitude: 'M 5,1',
        location: 'Samarinda, Kalimantan Timur',
        time: '27 Sep 2026 • 23:07 WITA',
        feltArea: 'Samarinda dan Kutai Kartanegara',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Gempa Dirasakan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Container(height: 5),
        const Text(
          'Ringkasan kejadian yang dirasakan masyarakat.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Container(height: 12),
        for (var index = 0; index < events.length; index++) ...[
          _buildFeltEarthquakeCard(
            magnitude: events[index].magnitude,
            location: events[index].location,
            time: events[index].time,
            feltArea: events[index].feltArea,
            index: index,
          ),
          if (index != events.length - 1) Container(height: 10),
        ],
      ],
    );
  }

  Widget _buildFeltEarthquakeCard({
    required String magnitude,
    required String location,
    required String time,
    required String feltArea,
    required int index,
  }) {
    final accent = index == 2
        ? const Color(0xFFE73F1E)
        : const Color(0xFFFB6C00);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E9E4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E4A35).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 74,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  magnitude,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                Container(height: 5),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF292421),
                  ),
                ),
                Container(height: 6),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Container(height: 6),
                Text(
                  'Dirasakan di $feltArea',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5D514A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onOpenPenilaian,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA17C), Color(0xFFFFC5A6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE73F1E).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFC83A18),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              Container(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Penilaian Kesiapsiagaan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7F2108),
                        height: 1.25,
                      ),
                    ),
                    Container(height: 6),
                    const Text(
                      'Cek tingkat kesiapsiagaanmu sekarang!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF813014),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8F2A0D),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestEarthquakeLabel extends StatelessWidget {
  const _LatestEarthquakeLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded, color: Color(0xFFFFDD9C), size: 16),
          Container(width: 6),
          Text(
            'Gempa Terkini',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9B637),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'BMKG',
        style: TextStyle(
          color: Color(0xFFE73F1E),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _MagnitudeText extends StatelessWidget {
  const _MagnitudeText({required this.fontSize, required this.magnitude});

  final double fontSize;
  final String magnitude;

  @override
  Widget build(BuildContext context) {
    return Text(
      'M $magnitude',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1,
      ),
    );
  }
}

class _LatestEarthquakeDetails extends StatelessWidget {
  const _LatestEarthquakeDetails({
    required this.earthquake,
    required this.isLoading,
    required this.hasError,
  });

  final Earthquake? earthquake;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final event = earthquake;
    if (event == null) {
      return _EarthquakeDetailRow(
        icon: hasError ? Icons.cloud_off_rounded : Icons.sync_rounded,
        text: hasError
            ? 'Data BMKG gagal dimuat. Tekan coba lagi.'
            : isLoading
            ? 'Sedang mengambil data dari BMKG...'
            : 'Data gempa belum tersedia.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EarthquakeDetailRow(
          icon: Icons.access_time_rounded,
          text: '${event.date} • ${event.time}',
        ),
        Container(height: 8),
        _EarthquakeDetailRow(
          icon: Icons.location_on_rounded,
          text: event.region,
        ),
        Container(height: 8),
        _EarthquakeDetailRow(
          icon: Icons.layers_outlined,
          text: 'Kedalaman ${event.depth}',
        ),
        Container(height: 8),
        _EarthquakeDetailRow(
          icon: Icons.info_outline_rounded,
          text: event.potential,
        ),
      ],
    );
  }
}

class _EarthquakeDetailRow extends StatelessWidget {
  const _EarthquakeDetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFD166), size: 16),
        Container(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _KotaPainter extends CustomPainter {
  const _KotaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final matahari = Paint()
      ..color = const Color(0xFFFFDD9C).withValues(alpha: 0.9);
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.22),
      size.width * 0.16,
      matahari,
    );

    final gunungJauh = Paint()
      ..color = const Color(0xFFE73F1E).withValues(alpha: 0.35);
    final pathJauh = Path()
      ..moveTo(0, size.height * 0.62)
      ..lineTo(size.width * 0.28, size.height * 0.32)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.72, size.height * 0.28)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathJauh, gunungJauh);

    final gunungDekat = Paint()
      ..color = const Color(0xFFE73F1E).withValues(alpha: 0.55);
    final pathDekat = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.22, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.62, size.height * 0.45)
      ..lineTo(size.width * 0.85, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathDekat, gunungDekat);

    final gedung = Paint()
      ..color = const Color(0xFFFFDD9C).withValues(alpha: 0.9);
    final jendela = Paint()
      ..color = const Color(0xFFE73F1E).withValues(alpha: 0.7);
    final tinggiRelatif = [0.28, 0.4, 0.22, 0.48, 0.3, 0.36, 0.24];
    final jumlahGedung = tinggiRelatif.length;
    final lebarGedung = size.width / jumlahGedung;
    for (int i = 0; i < jumlahGedung; i++) {
      final tinggiGedung = size.height * tinggiRelatif[i];
      final x = i * lebarGedung + lebarGedung * 0.08;
      final lebar = lebarGedung * 0.84;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, size.height - tinggiGedung, lebar, tinggiGedung),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rect, gedung);

      if (tinggiGedung > size.height * 0.3) {
        canvas.drawCircle(
          Offset(x + lebar / 2, size.height - tinggiGedung * 0.6),
          lebar * 0.12,
          jendela,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
