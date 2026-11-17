
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'wilayah_screen.dart';
import '../models/penilaian_result.dart';
import '../services/earthquake_service.dart';
import 'penilaian_screen.dart';
import 'riwayat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    this.earthquakeService = const EarthquakeService(),
  });

  final EarthquakeService earthquakeService;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<PenilaianResult> _penilaianHistory = [];

  void _savePenilaian(PenilaianResult result) {
    setState(() => _penilaianHistory.insert(0, result));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AccountScreen(),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFB6C00)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : Colors.grey.shade600,
              size: 22,
            ),
            Container(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Colors.grey.shade600,
                fontSize: 11,
                fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.normal,
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
        onOpenAccount: _openAccount,
        earthquakeService: widget.earthquakeService,
      ),
      const WilayahScreen(),
      PenilaianScreen(onSave: _savePenilaian),
      RiwayatScreen(penilaianHistory: _penilaianHistory),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 20,
          left: 20,
          right: 20,
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
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

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _getUserName(User user) {
    final metadata = user.userMetadata;
    final name = metadata?['full_name']?.toString();

    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    return user.email?.split('@').first ?? 'Pengguna SIAGA';
  }

  
Future<void> _logout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun SIAGA?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE73F1E),
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      );
    },
  );

  if (confirm != true || !context.mounted) return;

  try {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    // Kembali ke halaman pertama setelah AuthGate
    // mendeteksi bahwa sesi sudah berakhir.
    Navigator.of(context).popUntil((route) => route.isFirst);

  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal keluar: $error'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Tidak ada akun yang sedang aktif.'),
        ),
      );
    }

    final name = _getUserName(user);
    final initial = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'P';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF28231F),
        elevation: 0,
        title: const Text(
          'Informasi Akun',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),

          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFFB6C00),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const Center(
            child: Text(
              'Pengguna SIAGA',
              style: TextStyle(
                color: Color(0xFF817970),
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 35),

          const Text(
            'Detail Akun',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          _accountDetail(
            label: 'Nama Pengguna',
            value: name,
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 18),

          _accountDetail(
            label: 'Email',
            value: user.email ?? '-',
            icon: Icons.email_outlined,
          ),

          const SizedBox(height: 35),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE73F1E),
              ),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(
                  color: Color(0xFFE73F1E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                side: const BorderSide(
                  color: Color(0xFFE73F1E),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountDetail({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFFFB6C00),
          size: 23,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF817970),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF28231F),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
