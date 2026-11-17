import 'package:flutter/material.dart';

import '../models/penilaian_result.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key, this.penilaianHistory = const []});

  final List<PenilaianResult> penilaianHistory;

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.of(context).size.width;
    final statusBar = MediaQuery.of(context).padding.top;
    final pad = lebar * 0.06;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(pad, statusBar + 20, pad, 18),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(0xFFE73F1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                Container(width: 14),
                Expanded(
                  child: Text(
                    'Riwayat Penilaian',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (penilaianHistory.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Center(
                      child: _buildEmptyState(),
                    ),
                  )
                else
                  ...penilaianHistory.map(
                    (result) => _buildPenilaianCard(context, result),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFFFB6C00),
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belum Ada Riwayat Penilaian',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF20242A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu belum menyelesaikan penilaian kesiapsiagaan. '
            'Hasil penilaianmu akan muncul di sini setelah selesai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6C7076),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPenilaianCard(BuildContext context, PenilaianResult result) {
    final isStrong = result.score >= 5;
    final isLow = result.score <= 2;
    final badgeColor = isStrong
        ? const Color(0xFFE3F3EA)
        : isLow
        ? const Color(0xFFFFE8DF)
        : const Color(0xFFFFF0D9);
    final badgeTextColor = isStrong
        ? const Color(0xFF238052)
        : isLow
        ? const Color(0xFFD44724)
        : const Color(0xFFE67A00);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFF1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showPenilaianDetail(context, result),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2E7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: Color(0xFFFB6C00),
                    size: 21,
                  ),
                ),
                Container(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF252A30),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(height: 5),
                      Text(
                        'Skor kesiapsiagaan: ${result.score} dari ${result.answers.length}',
                        style: const TextStyle(
                          color: Color(0xFF697078),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 112),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF77736F),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPenilaianDetail(BuildContext context, PenilaianResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D3CE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(height: 20),
              const Text(
                'Detail Penilaian',
                style: TextStyle(
                  color: Color(0xFF252A30),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(height: 5),
              Text(
                result.formattedDate,
                style: const TextStyle(color: Color(0xFF737980), fontSize: 13),
              ),
              Container(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hasil Penilaian Kesiapsiagaan',
                      style: TextStyle(color: Color(0xFF62666D), fontSize: 12),
                    ),
                    Container(height: 6),
                    Text(
                      '${result.score} dari ${result.answers.length} · ${result.category}',
                      style: const TextStyle(
                        color: Color(0xFF252A30),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(height: 6),
                    Text(
                      result.description,
                      style: const TextStyle(
                        color: Color(0xFF62666D),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Penilaian mandiri berdasarkan enam indikator, bukan penilaian resmi BMKG.',
                  style: TextStyle(
                    color: Color(0xFF858A90),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
              Container(height: 18),
              const Text(
                'Jawaban penilaian',
                style: TextStyle(
                  color: Color(0xFF252A30),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(height: 8),
              for (var index = 0; index < result.answers.length; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        result.answers[index]
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: result.answers[index]
                            ? const Color(0xFF27966A)
                            : const Color(0xFFE73F1E),
                        size: 18,
                      ),
                      Container(width: 9),
                      Expanded(
                        child: Text(
                          PenilaianResult.questions[index],
                          style: const TextStyle(
                            color: Color(0xFF555B62),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Container(width: 8),
                      Text(
                        result.answers[index] ? 'Ya' : 'Tidak',
                        style: TextStyle(
                          color: result.answers[index]
                              ? const Color(0xFF238052)
                              : const Color(0xFFD44724),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(height: 12),
              const Text(
                'Hal yang perlu ditingkatkan',
                style: TextStyle(
                  color: Color(0xFF252A30),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(height: 8),
              if (result.improvements.isEmpty)
                const Text(
                  'Semua indikator sudah terpenuhi. Pertahankan kesiapsiagaanmu.',
                  style: TextStyle(
                    color: Color(0xFF62666D),
                    fontSize: 13,
                    height: 1.45,
                  ),
                )
              else
                for (var index = 0; index < result.answers.length; index++)
                  if (!result.answers[index])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color(0xFFFB6C00),
                            size: 8,
                          ),
                          Container(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  PenilaianResult.improvementTitles[index],
                                  style: const TextStyle(
                                    color: Color(0xFF34383D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(height: 4),
                                Text(
                                  PenilaianResult.recommendations[index],
                                  style: const TextStyle(
                                    color: Color(0xFF62666D),
                                    fontSize: 12,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
