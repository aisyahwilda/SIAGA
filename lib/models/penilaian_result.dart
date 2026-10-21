class PenilaianResult {
  PenilaianResult({required List<bool> answers, required this.completedAt})
    : answers = List.unmodifiable(answers);

  static const questions = <String>[
    'Mengetahui lokasi titik kumpul terdekat',
    'Sudah menyiapkan tas siaga bencana',
    'Mengetahui jalur evakuasi',
    'Mengetahui nomor yang dapat dihubungi saat darurat',
    'Memiliki persediaan air dan makanan untuk 3 hari',
    'Memiliki kesepakatan rencana evakuasi keluarga',
  ];

  static const recommendations = <String>[
    'Cari tahu lokasi titik kumpul terdekat dari rumah dan tempat aktivitasmu.',
    'Siapkan tas siaga berisi kebutuhan penting untuk keadaan darurat.',
    'Kenali jalur evakuasi dan alternatifnya dari tempat tinggalmu.',
    'Simpan nomor darurat di ponsel dan di tempat yang mudah ditemukan.',
    'Siapkan air minum dan makanan yang cukup untuk kebutuhan darurat selama 3 hari.',
    'Diskusikan jalur evakuasi dan titik berkumpul bersama anggota keluarga.',
  ];

  static const improvementTitles = <String>[
    'Lokasi titik kumpul',
    'Tas siaga bencana',
    'Jalur evakuasi',
    'Nomor darurat',
    'Persediaan kebutuhan darurat',
    'Rencana evakuasi keluarga',
  ];

  final List<bool> answers;
  final DateTime completedAt;

  int get score => answers.where((answer) => answer).length;

  String get category {
    if (score <= 2) return 'Perlu Ditingkatkan';
    if (score <= 4) return 'Cukup Siap';
    return 'Lebih Siap';
  }

  String get description {
    if (score <= 2) {
      return 'Masih ada beberapa aspek dasar kesiapsiagaan yang perlu dipersiapkan.';
    }
    if (score <= 4) {
      return 'Sebagian aspek sudah dipersiapkan, tetapi masih ada hal yang perlu dilengkapi.';
    }
    return 'Sebagian besar aspek sudah dipersiapkan. Evaluasi kesiapsiagaan secara berkala.';
  }

  List<String> get improvements => [
    for (var index = 0; index < answers.length; index++)
      if (!answers[index]) recommendations[index],
  ];

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final date = completedAt;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute';
  }
}
