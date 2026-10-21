// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:siaga_gempa/main.dart';
import 'package:siaga_gempa/models/penilaian_result.dart';
import 'package:siaga_gempa/screens/home_screen.dart';
import 'package:siaga_gempa/screens/login_screen.dart';
import 'package:siaga_gempa/screens/penilaian_screen.dart';
import 'package:siaga_gempa/screens/riwayat_screen.dart';
import 'package:siaga_gempa/screens/wilayah_screen.dart';

void main() {
  testWidgets('Login and registration screens fit a narrow mobile screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Masuk ke SIAGA'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Lupa kata sandi?'), findsNothing);
    expect(find.text('Remember me'), findsNothing);
    expect(find.textContaining('continue with'), findsNothing);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Buat akun'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Remember me'), findsNothing);
    expect(find.textContaining('continue with'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Registered account can sign in', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'aisyah@siaga.id');
    await tester.enterText(find.byType(TextFormField).at(1), 'aman1234');
    await tester.enterText(find.byType(TextFormField).at(2), 'salah1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Kata sandi belum sama'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'aman1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Pendaftaran berhasil. Silakan masuk.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), 'keliru1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Email atau kata sandi tidak cocok dengan akun terdaftar.'),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'aman1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Aisyah'), findsOneWidget);
    expect(find.text('Gempa Terkini'), findsOneWidget);
    expect(find.text('Gempa Dirasakan'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsNothing);
    expect(find.text('BMKG'), findsOneWidget);
    expect(find.text('M 4,8'), findsOneWidget);
    expect(find.text('M 3,6'), findsOneWidget);
    expect(find.text('M 5,1'), findsOneWidget);
    expect(find.text('Dirasakan di Paser dan Tanah Grogot'), findsOneWidget);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Aisyah'), findsOneWidget);
  });

  testWidgets('Home screen fits a narrow mobile screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var openedEvaluation = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SiagaHomePage(
            onOpenWilayah: () {},
            onOpenPenilaian: () => openedEvaluation = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('SIAGA'), findsOneWidget);
    expect(find.text('M 4,8'), findsOneWidget);
    expect(find.text('M 3,6'), findsOneWidget);
    expect(find.text('M 5,1'), findsOneWidget);
    expect(find.text('Halo, Aisyah'), findsOneWidget);
    expect(find.text('BMKG'), findsOneWidget);
    expect(find.byIcon(Icons.waving_hand_rounded), findsNothing);
    final evaluationTitle = tester.widget<Text>(
      find.text('Penilaian Kesiapsiagaan'),
    );
    expect(evaluationTitle.style?.fontSize, 16);
    expect(find.text('Cek tingkat kesiapsiagaanmu sekarang!'), findsOneWidget);
    expect(find.byIcon(Icons.fact_check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Penilaian Kesiapsiagaan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Penilaian Kesiapsiagaan'));
    expect(openedEvaluation, isTrue);
  });

  testWidgets('Wilayah adapts to a narrow mobile screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: const Scaffold(body: WilayahScreen())),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Pilih Wilayah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balikpapan').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Pilihan'));
    await tester.pumpAndSettle();

    expect(find.text('Balikpapan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('M 3,6'));
    await tester.tap(find.text('M 3,6'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Gempa'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Lokasi Pusat Gempa'), findsOneWidget);
    expect(
      find.textContaining('Penanda ini hanya ilustrasi area'),
      findsOneWidget,
    );
    expect(find.text('1.24° LS, 116.83° BT'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Region picker filters and replaces the active region', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await _loginToApp(tester);

    await tester.tap(find.text('Wilayah'));
    await tester.pumpAndSettle();
    expect(find.text('Belum Ada Wilayah Pantauan'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Belum Ada Wilayah Pantauan')).dy,
      greaterThan(300),
    );

    await tester.tap(find.text('Pilih Wilayah'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Wilayah').last, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Balikpapan');
    await tester.pumpAndSettle();
    expect(find.text('Balikpapan'), findsNWidgets(2));
    expect(find.text('Samarinda'), findsNothing);
    expect(find.text('Palu'), findsNothing);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Samarinda'), findsOneWidget);
    expect(find.text('Bontang'), findsOneWidget);
    expect(find.text('Sangatta'), findsOneWidget);
    expect(find.text('Palu'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Balikpapan');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balikpapan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Pilihan'));
    await tester.pumpAndSettle();
    expect(find.text('Balikpapan'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/kota.png',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.text('Gempa Dirasakan'), findsOneWidget);
    expect(
      find.text(
        'Kejadian gempa yang dirasakan di wilayah Balikpapan berdasarkan data BMKG.',
      ),
      findsOneWidget,
    );
    expect(find.text('CONTOH'), findsNothing);
    expect(find.text('M 3,6'), findsOneWidget);
    expect(find.text('M 3,8'), findsOneWidget);
    expect(find.text('M 4,3'), findsOneWidget);
    expect(find.text('M 4,8'), findsNothing);

    await tester.ensureVisible(find.text('M 3,6'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('M 3,6'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Gempa'), findsOneWidget);
    expect(find.byIcon(Icons.monitor_heart_rounded), findsOneWidget);
    expect(find.text('Koordinat'), findsOneWidget);
    expect(find.text('Dirasakan'), findsNWidgets(2));
    expect(find.text('Potensi Tsunami'), findsOneWidget);
    expect(find.text('Lokasi Pusat Gempa'), findsOneWidget);
    expect(
      find.textContaining('Penanda ini hanya ilustrasi area'),
      findsOneWidget,
    );
    expect(find.text('1.24° LS, 116.83° BT'), findsNWidgets(2));
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ganti Wilayah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Samarinda');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Samarinda').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Pilihan'));
    await tester.pumpAndSettle();
    expect(find.text('Samarinda'), findsOneWidget);
    expect(find.text('Balikpapan'), findsNothing);
    expect(find.text('M 4,8'), findsOneWidget);
    expect(find.text('M 3,9'), findsOneWidget);
    expect(find.text('M 3,5'), findsOneWidget);
    expect(find.text('M 3,6'), findsNothing);

    await tester.tap(find.text('Siaga').last);
    await tester.pumpAndSettle();
    expect(find.text('Pertanyaan Kesiapsiagaan'), findsOneWidget);
    expect(find.byType(PenilaianScreen), findsOneWidget);

    await tester.tap(find.text('Riwayat').last);
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Penilaian'), findsNWidgets(2));
    expect(find.text('Riwayat Gempa'), findsNothing);
    expect(find.text('Total Gempa'), findsNothing);
    expect(find.text('Semua'), findsNothing);
  });

  testWidgets('Penilaian results show score and advice from No answers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PenilaianScreen())),
    );

    for (var index = 0; index < 6; index++) {
      final yesButton = find.text('✓  Ya').at(index);
      final noButton = find.text('✕  Tidak').at(index);
      await tester.ensureVisible(yesButton);
      await tester.tap(index < 4 ? yesButton : noButton);
      await tester.pumpAndSettle();
    }

    final finishButton = find.text('Lihat Hasil Penilaian');
    await tester.ensureVisible(finishButton);
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.text('4 dari 6 · Cukup Siap'), findsOneWidget);
    expect(find.text('Hal yang perlu ditingkatkan'), findsOneWidget);
    expect(find.text('Persediaan kebutuhan darurat'), findsOneWidget);
    expect(find.text('Rencana evakuasi keluarga'), findsOneWidget);
    expect(find.textContaining('3 hari'), findsOneWidget);
    expect(find.textContaining('anggota keluarga'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Penilaian header title remains visible on narrow mobile', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PenilaianScreen())),
    );

    expect(find.text('Cek Kesiapan Gempa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Penilaian categories follow the requested score ranges', () {
    for (var score = 0; score <= 6; score++) {
      final result = PenilaianResult(
        answers: List.generate(6, (index) => index < score),
        completedAt: DateTime(2026, 10, 21),
      );
      final expectedCategory = score <= 2
          ? 'Perlu Ditingkatkan'
          : score <= 4
          ? 'Cukup Siap'
          : 'Lebih Siap';

      expect(result.score, score);
      expect(result.category, expectedCategory);
      expect(result.improvements.length, 6 - score);
    }
  });

  testWidgets('Completed assessment is saved and opens from Riwayat', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await _loginToApp(tester);
    await tester.tap(find.text('Siaga').last);
    await tester.pumpAndSettle();

    for (var index = 0; index < 6; index++) {
      final yesButton = find.text('✓  Ya').at(index);
      final noButton = find.text('✕  Tidak').at(index);
      await tester.ensureVisible(yesButton);
      await tester.tap(index < 4 ? yesButton : noButton);
      await tester.pumpAndSettle();
    }
    final finishButton = find.text('Lihat Hasil Penilaian');
    await tester.ensureVisible(finishButton);
    await tester.drag(
      find
          .descendant(
            of: find.byType(PenilaianScreen),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Riwayat').last);
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Penilaian'), findsNWidgets(2));
    expect(find.textContaining('Skor kesiapsiagaan: 4 dari 6'), findsOneWidget);
    expect(find.text('Cukup Siap'), findsOneWidget);

    await tester.tap(find.textContaining('Skor kesiapsiagaan: 4 dari 6'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Penilaian'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Persediaan kebutuhan darurat'), findsOneWidget);
    expect(find.text('Rencana evakuasi keluarga'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Assessment history cards fit a narrow mobile screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RiwayatScreen(
            penilaianHistory: [
              PenilaianResult(
                answers: [true, true, false, true, false, true],
                completedAt: DateTime(2026, 10, 21, 10, 0),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Riwayat Penilaian'), findsNWidgets(2));
    expect(find.text('Cukup Siap'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(
      find.textContaining('Skor kesiapsiagaan: 4 dari 6'),
    );
    await tester.tap(find.textContaining('Skor kesiapsiagaan: 4 dari 6'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Penilaian'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wilayah shows sample-empty state for an unsupported region', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WilayahScreen())),
    );

    await tester.tap(find.text('Pilih Wilayah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bontang');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bontang').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Pilihan'));
    await tester.pumpAndSettle();

    expect(find.text('Wilayah Pantauan'), findsOneWidget);
    expect(find.text('Belum ada kejadian yang cocok'), findsOneWidget);
    expect(find.textContaining('wilayah Bontang.'), findsOneWidget);
    expect(find.textContaining('hanya menggunakan data contoh'), findsNothing);
    expect(find.text('Gempa Dirasakan'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _loginToApp(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'aisyah@siaga.id');
  await tester.enterText(find.byType(TextFormField).at(1), 'demopassword');
  await tester.enterText(find.byType(TextFormField).at(2), 'demopassword');
  await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'aisyah@siaga.id');
  await tester.enterText(find.byType(TextFormField).at(1), 'demopassword');
  await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
  await tester.pumpAndSettle();
}
