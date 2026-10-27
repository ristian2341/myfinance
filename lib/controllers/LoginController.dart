import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfinance/utils/database_service.dart'; // 1. IMPORT SERVICE DATABASE ANDA
import 'package:myfinance/views/login_screen.dart';
import 'package:myfinance/repository/SettingRepository.dart';
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:myfinance/models/SettingModel.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginController extends GetxController {
  final box = GetStorage();

  // 2. PANGGIL INSTANCE DATABASE YANG SUDAH JALAN
  final DatabaseService _dbService = Get.find<DatabaseService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var namaAplikasi = ''.obs;
  var logoAplikasi = ''.obs;
  var iconApplikasi = ''.obs;
  var namaInstansi = ''.obs;

  bool get isLoggedIn => box.read('isLoggedIn') ?? false;

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Validasi dasar input kosong
    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.warning(
        'Email dan Password tidak boleh kosong!',
        title: 'Peringatan',
      );
      return;
    }

    try {
      isLoading.value = true;

      // Simulasi delay sedikit agar transisi terasa smooth
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. QUERY COCOKKAN KE DATABASE (Mencari di tabel user)
      final List<Map<String, dynamic>> result = await _dbService.db.query(
        'user',
        where: 'username = ?',
        whereArgs: [email],
      );

      // 4. JIKA DATA USER DITEMUKAN
      if (result.isNotEmpty) {
        final user = result.first; // Ambil baris data user pertama yang cocok

        // 1. Ambil Password dari Database (yang sudah di-hash)
        final String storedPassword = user['password'];

        // 2. Cek apakah input user cocok dengan hash yang tersimpan di DB
        final bool isPasswordValid = BCrypt.checkpw(password, storedPassword);

        if (!isPasswordValid) {
          // Jika hash tidak cocok, keluar dari blok if
          SnackbarHelper.danger(
            'Username atau Password salah!',
            title: 'Gagal Login',
          );
          return; // Hentikan fungsi login di sini
        }

        // Jika hash cocok, lanjutkan ke langkah berikutnya (Simpan session)
        // Simpan data session secara dinamis dari database ke GetStorage
        await box.write('isLoggedIn', true);
        await box.write('userCode', user['code']);
        await box.write('userEmail', user['email']);
        await box.write('namauser', user['nama_panggilan']);
        await box.write('username', user['username']);
        await box.write('userFoto', user['foto'] ?? '');
        await box.write('developer', user['developer'] ?? 0);
        await box.write('supervisor', user['supervisor'] ?? 0);
        await box.write('accessToken', user['access_token'] ?? '');

        // Notifikasi Sukses
        SnackbarHelper.success(
          'Selamat datang kembali, ${user['nama_panggilan']}!',
          title: 'Sukses',
        );

        // Navigasi ke halaman Home (bersihkan stack halaman)
        Get.offAllNamed('/home');
      } else {
        // Jika query menghasilkan data kosong (username/password salah)
        SnackbarHelper.danger(
          'Username atau Password salah!',
          title: 'Gagal Login',
        );
      }
    } catch (e) {
      SnackbarHelper.danger('Terjadi kesalahan database: $e', title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await box.erase(); // Hapus session
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    muatSettingAplikasi();
    super.onInit();
  }

  // 3. Fungsi untuk mengambil data dari DB dan mengisi variabel public
  Future<void> muatSettingAplikasi() async {
    try {
      final repo = SettingRepository(_dbService.db);
      SettingModel? appSetting = await repo.getSettingApp();
      // Isi variabel public dengan data dari DB
      namaAplikasi.value = appSetting?.namaAplikasi ?? 'Finance & Accounting';
      logoAplikasi.value =
          appSetting?.logo ?? 'assets/images/finance_accounting.png';
      iconApplikasi.value = appSetting?.iconApp ?? 'assets/images/app_icon.ico';
      namaInstansi.value = appSetting?.instansi ?? 'My Finance Corp.';
    } catch (e) {
      print('Gagal memuat setting di controller: $e');
    }
  }
}
