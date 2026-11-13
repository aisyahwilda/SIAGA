import 'package:flutter/material.dart';

import '../models/penilaian_result.dart';

class _PertanyaanKesiapsiagaan {
  const _PertanyaanKesiapsiagaan({required this.teks, required this.icon});

  final String teks;
  final IconData icon;
}

class PenilaianScreen extends StatefulWidget {
  const PenilaianScreen({super.key, this.onSave});

  final ValueChanged<PenilaianResult>? onSave;

  @override
  State<PenilaianScreen> createState() => _PenilaianScreenState();
}

class _PenilaianScreenState extends State<PenilaianScreen> {
  static const _pertanyaan = <_PertanyaanKesiapsiagaan>[
    _PertanyaanKesiapsiagaan(
      teks: 'Apakah kamu mengetahui lokasi titik kumpul terdekat dari tempat tinggalmu?',
      icon: Icons.group_outlined,
    ),
    _PertanyaanKesiapsiagaan(
      teks: 'Apakah kamu sudah menyiapkan tas siaga bencana?',
      icon: Icons.backpack_outlined,
    ),
    _PertanyaanKesiapsiagaan(
      teks: 'Apakah kamu mengetahui jalur evakuasi dari tempat tinggalmu?',
      icon: Icons.directions_run_outlined,
    ),
    _PertanyaanKesiapsiagaan(
      teks: 'Apakah kamu mengetahui nomor yang dapat dihubungi dalam keadaan darurat?',
      icon: Icons.phone_in_talk_outlined,
    ),
    _PertanyaanKesiapsiagaan(
      teks: 'Apakah kamu memiliki persediaan air minum dan makanan yang cukup untuk kebutuhan darurat selama 3 hari?',
      icon: Icons.water_drop_outlined,
    ),
    _PertanyaanKesiapsiagaan(
      teks: 'Apakah kamu dan keluargamu sudah menyepakati rencana evakuasi jika terjadi gempa?',
      icon: Icons.family_restroom_outlined,
    ),
  ];

  late List<bool?> _jawaban;
  bool _sudahSelesai = false;

  @override
  void initState() {
    super.initState();
    _jawaban = List.filled(_pertanyaan.length, null);
  }

  bool get _semuaDijawab => _jawaban.every((j) => j != null);

  void _selesai() {
    if (_semuaDijawab) {
      widget.onSave?.call(
        PenilaianResult(
          answers: _jawaban.cast<bool>(),
          completedAt: DateTime.now(),
        ),
      );
      setState(() => _sudahSelesai = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawab semua pertanyaan terlebih dahulu!'),
          backgroundColor: Color(0xFFE73F1E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _ulangi() {
    setState(() {
      _jawaban = List.filled(_pertanyaan.length, null);
      _sudahSelesai = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final statusBar = MediaQuery.paddingOf(context).top;
    final y = (screenSize.height * 0.1).clamp(64.0, 80.0).toDouble();
    final pad = (screenSize.width * 0.06).clamp(18.0, 24.0).toDouble();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(statusBar: statusBar, y: y, pad: pad),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20),

                if (_sudahSelesai)
                  _buildHasilEvaluasi()
                else ...[
                  _buildProgressBar(),
                  Container(height: 24),
                  const Text(
                    'Pertanyaan Kesiapsiagaan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 6),
                  const Text(
                    'Jawab dengan jujur untuk mengetahui tingkat kesiapsiagaanmu.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Container(height: 16),
                  ..._pertanyaan.asMap().entries.map((entry) {
                    return _buildPertanyaanCard(
                      index: entry.key,
                      data: entry.value,
                    );
                  }),
                  Container(height: 16),
                  _buildTombolSelesai(),
                ],

                Container(height: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required double statusBar,
    required double y,
    required double pad,
  }) {
    return Container(
      padding: EdgeInsets.only(top: statusBar + 8, bottom: y * 0.2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE0D2), Color(0xFFFAFAFA)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: y * 0.6),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: pad),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE73F1E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fact_check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Container(width: 8),
                        const Expanded(
                          child: Text(
                            'Cek Kesiapan Gempa',
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: y * 0.12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: const Text(
              'Cek tingkat kesiapsiagaanmu menghadapi gempa',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final terjawab = _jawaban.where((j) => j != null).length;
    final persen = terjawab / _pertanyaan.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Progress Jawaban',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '$terjawab/${_pertanyaan.length}',
                style: const TextStyle(
                  color: Color(0xFFFB6C00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: persen,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFB6C00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPertanyaanCard({
    required int index,
    required _PertanyaanKesiapsiagaan data,
  }) {
    final jawaban = _jawaban[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: jawaban == null
              ? Colors.grey.shade200
              : jawaban == true
              ? const Color(0xFF27AE60).withValues(alpha: 0.4)
              : const Color(0xFFE73F1E).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  data.icon,
                  color: const Color(0xFFFB6C00),
                  size: 20,
                ),
              ),
              Container(width: 12),
              Expanded(
                child: Text(
                  '${index + 1}. ${data.teks}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Container(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _jawaban[index] = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: jawaban == true
                          ? const Color(0xFF27AE60)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '✓  Ya',
                        style: TextStyle(
                          color: jawaban == true
                              ? Colors.white
                              : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _jawaban[index] = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: jawaban == false
                          ? const Color(0xFFE73F1E)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '✕  Tidak',
                        style: TextStyle(
                          color: jawaban == false
                              ? Colors.white
                              : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTombolSelesai() {
    return GestureDetector(
      onTap: _selesai,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE73F1E), Color(0xFFFB6C00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE73F1E).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Lihat Hasil Penilaian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHasilEvaluasi() {
    final result = PenilaianResult(
      answers: _jawaban.cast<bool>(),
      completedAt: DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF5E2D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Color(0xFFE73F1E),
                  size: 27,
                ),
              ),
              Container(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tingkat Kesiapsiagaan',
                      style: TextStyle(
                        color: Color(0xFF5E6268),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(height: 5),
                    Text(
                      '${result.score} dari ${result.answers.length} · ${result.category}',
                      style: const TextStyle(
                        color: Color(0xFF20242A),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(height: 6),
                    Text(
                      result.description,
                      style: const TextStyle(
                        color: Color(0xFF6C7076),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Container(height: 20),

        const Text(
          'Hal yang perlu ditingkatkan',
          style: TextStyle(
            color: Color(0xFF20242A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(height: 10),
        if (result.improvements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8F3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Semua indikator sudah terpenuhi. Pertahankan kesiapsiagaanmu.',
              style: TextStyle(
                color: Color(0xFF386B50),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          )
        else
          for (var index = 0; index < result.answers.length; index++)
            if (!result.answers[index])
              _buildImprovementCard(
                PenilaianResult.improvementTitles[index],
                PenilaianResult.recommendations[index],
              ),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            'Penilaian mandiri berdasarkan enam indikator, bukan penilaian resmi BMKG.',
            style: TextStyle(
              color: Color(0xFF858A90),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
        Container(height: 20),
        GestureDetector(
          onTap: _ulangi,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Ulangi Penilaian',
                style: TextStyle(
                  color: Color(0xFFFB6C00),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementCard(String title, String description) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF34383D),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(height: 5),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF6C7076),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
