import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'wilayah_screen.dart';
import '../models/penilaian_result.dart';
import 'penilaian_screen.dart';
import 'riwayat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // buat variable penanda tab mana yang sedang aktif, mulainya dari index 0
  int _selectedIndex = 0;

  final List<PenilaianResult> _penilaianHistory = [];

  void _savePenilaian(PenilaianResult result) {
    setState(() => _penilaianHistory.insert(0, result));
  }

  // fungsi yang dipanggil ketika tombol menu dipencet
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // ini tuh ngubah state index
    });
  }

  // Fungsi untuk merakit tombol menu (Custom Navbar Item)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive =
        _selectedIndex == index; // ngecek apakah menu ini sedang dipilih

    return GestureDetector(
      onTap: () =>
          _onItemTapped(index), // memanggil fungsi ganti halaman saat diklik
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // animasi smooth
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ), // FIX: kurangi padding vertical
        decoration: BoxDecoration(
          // kalo aktif, pake warna oren FB6C00. kalo gak aktif transparan
          color: isActive ? const Color(0xFFFB6C00) : Colors.transparent,
          borderRadius: BorderRadius.circular(30), // bikin kapsul background
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // agar kolom gak tembus pandang ke atas
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              // jika aktif warna putih, kalo gak aktif warna abu-abu
              color: isActive ? Colors.white : Colors.grey.shade600,
              size: 22, // FIX: kurangi ukuran icon dari 26 ke 22
            ),
            const SizedBox(height: 2), // FIX: kurangi jarak dari 4 ke 2
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontSize: 11, // FIX: kurangi dari 12 ke 11
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SiagaHomePage(
        onOpenWilayah: () => _onItemTapped(1),
        onOpenPenilaian: () => _onItemTapped(2),
      ),
      const WilayahScreen(),
      PenilaianScreen(onSave: _savePenilaian),
      RiwayatScreen(penilaianHistory: _penilaianHistory),
    ];

    return Scaffold(
      // agar halaman bisa menyentuh ujung bawah layar
      extendBody: true,

      // IndexedStack mempertahankan state setiap tab saat pengguna berpindah halaman.
      body: IndexedStack(index: _selectedIndex, children: pages),

      // navbar melayang yang keren
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Container(
          height: 72, // FIX: turunkan dari 80 ke 72 supaya lebih compact
          decoration: BoxDecoration(
            color: Colors.white, // warna dasar navbar
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home,
                  label: 'Beranda',
                  index: 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.map,
                  label: 'Wilayah',
                  index: 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.check_circle_outline,
                  label: 'Siaga',
                  index: 2,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.history,
                  label: 'Riwayat',
                  index: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
