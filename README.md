# SIAGA

Aplikasi Flutter untuk melihat informasi gempa dan mengecek kesiapsiagaan.

## Integrasi API BMKG

Beranda mengambil data gempa terbaru dari endpoint publik BMKG:

`https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json`

Alur datanya:

1. `EarthquakeService` mengirim HTTP GET dan memeriksa status serta format respons.
2. `Earthquake.fromJson` mengubah data JSON menjadi model Dart.
3. Kartu **Gempa Terkini** menampilkan magnitudo, waktu, lokasi, kedalaman, dan informasi potensi.
4. Saat permintaan berlangsung, aplikasi menampilkan status memuat. Jika gagal, pengguna dapat mencoba lagi.

Izin internet Android ditambahkan di `android/app/src/main/AndroidManifest.xml`.

Jalankan aplikasi dengan `flutter run`. Untuk memeriksa kode dan tes:

```shell
flutter analyze
flutter test
```
