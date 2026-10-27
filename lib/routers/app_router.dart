// lib/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:myfinance/utils/snackbar_helper.dart';

// Memanggil satu file pintu masuk utama untuk semua screen
import 'package:myfinance/utils/screens.dart';
import 'package:myfinance/views/group_menu_screen.dart';

class AppRouter {
  /// Peta Router Dinamis (Registry)
  static final Map<String, Widget> registry = {
    'setting_screen.dart': const SettingScreen(),
    'menu_screen.dart': const MenuScreen(),
    'user_screen.dart': const UserScreen(),
    'group_menu_screen.dart': GroupMenuScreen(),
  };

  /// Fungsi Pembantu (Helper) untuk mengambil Widget halaman secara dinamis.
  static Widget dapatkanHalaman(String? urlMenu) {
    // 1. Validasi jika kolom url_menu di database bernilai NULL atau kosong
    if (urlMenu == null || urlMenu.trim().isEmpty) {
      // Munculkan snackbar pemberitahuan
      SnackbarHelper.danger("Halaman Menu tidak ditemukan atau URL kosong!");

      // KUNCI: Langsung return halaman error bawaan agar fungsi berhenti dan tidak crash
      return _halamanTidakDitemukan("Kosong / Null");
    }

    // 2. Bersihkan string dari spasi yang tidak disengaja
    final String keyBersih = urlMenu.trim().toLowerCase();

    // 3. Cari widget di registry berdasarkan key.
    if (registry.containsKey(keyBersih)) {
      return registry[keyBersih]!;
    } else {
      // Jika teks ada di SQLite tapi lupa didaftarkan di kode registry:
      SnackbarHelper.danger("Routing gagal: '$urlMenu' belum terdaftar!");
      return _halamanTidakDitemukan(urlMenu);
    }
  }

  /// Halaman Fallback / Error jika teks di DB SQLite tidak terdaftar di registry
  static Widget _halamanTidakDitemukan(String urlMenu) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        30,
        30,
        40,
      ), // Menyesuaikan tema gelap Anda
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.report_gmailerrorred_rounded,
                color: Colors.amber,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'MAPPING ROUTER GAGAL',
                style: TextStyle(
                  color: Colors.amber[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'File atau string "$urlMenu" terdeteksi di SQLite, tetapi belum didaftarkan ke dalam AppRouter.registry.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
