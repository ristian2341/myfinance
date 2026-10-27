import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfinance/repository/SettingRepository.dart';
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:myfinance/utils/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myfinance/models/SettingModel.dart';

class SettingController extends GetxController {
  final box = GetStorage();
  // Langsung tembak properti .db dari Get.find
  final Database db = Get.find<DatabaseService>().db;

  // variable untuk update data //
  final namaAplikasiController = TextEditingController();
  final instansiController = TextEditingController();
  final logoAplikasiController = TextEditingController();
  final backgroundAppController = TextEditingController();
  final iconApplikasiController = TextEditingController();
  final emailNotifController = TextEditingController();
  final passwordNotifController = TextEditingController();
  final alamatInstansiController = TextEditingController();
  final kabupatenController = TextEditingController();
  final provinsiController = TextEditingController();
  final namaInstansiController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var namaAplikasi = ''.obs;
  var logoAplikasi = ''.obs;
  var iconApplikasi = ''.obs;

  bool get isLoggedIn => box.read('isLoggedIn') ?? false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    dataSetting();
  }

  // Tambahkan variabel idSetting untuk melacak id data saat ini
  var idSettingTemp = 1.obs; // Default 1 jika data baru awal

  Future<void> dataSetting() async {
    try {
      isLoading.value = true;
      final repoSetting = SettingRepository(db);
      final setting = await repoSetting.getSettingApp();

      if (setting == null) {
        SnackbarHelper.danger('Data setting tidak ditemukan', title: 'Error');
        return;
      }
      // ✨ Simpan idSetting dari database agar saat update target ID-nya tepat
      idSettingTemp.value = setting.idSetting ?? 1;

      namaAplikasiController.text = setting.namaAplikasi;
      instansiController.text = setting.instansi ?? '';
      logoAplikasiController.text = setting.logo ?? '';
      backgroundAppController.text = setting.backgroundApp ?? '';
      iconApplikasiController.text = setting.iconApp ?? '';
      emailNotifController.text = setting.emailNotif ?? '';
      passwordNotifController.text = setting.passwordNotif ?? '';
      namaAplikasi.value = setting.namaAplikasi;
      logoAplikasi.value = setting.logo ?? '';
      iconApplikasi.value = setting.iconApp ?? '';
      namaInstansiController.text = setting.namaInstansi ?? '';
      alamatInstansiController.text = setting.alamatInstansi ?? '';
      kabupatenController.text = setting.kabupaten ?? '';
      provinsiController.text = setting.profinsi ?? '';
    } catch (e) {
      SnackbarHelper.danger('Terjadi kesalahan database: $e', title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi memilih file Logo
  Future<void> pickLogoFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'], // Batasi hanya gambar
    );

    if (result != null) {
      // Mengisi text controller dengan nama file yang dipilih
      logoAplikasiController.text = result.files.single.name;

      // TIPS: Jika butuh path asli/bytes file untuk diupload nanti:
      // String? filePath = result.files.single.path;
      // Uint8List? fileBytes = result.files.single.bytes; (Untuk Web)
    }
  }

  // Fungsi memilih file Icon
  Future<void> pickIconFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ico', 'png'], // Batasi ekstensi ikon
    );

    if (result != null) {
      iconApplikasiController.text = result.files.single.name;
    }
  }

  ///update or insert setting //
  // 2. TRAMPILAN FUNGSI INPUT UTAMA UNTUK DI PANGGIL DI TOMBOL SIMPAN
  Future<void> updateSettingData() async {
    // Validasi dasar jika input wajib diisi
    if (namaAplikasiController.text.trim().isEmpty) {
      SnackbarHelper.danger('Nama aplikasi tidak boleh kosong!');
      return;
    }

    try {
      isLoading.value = true;

      // Ambil instance koneksi database dari GetxService
      final dbService = Get.find<DatabaseService>();
      final repo = SettingRepository(dbService.db);

      // Buat objek SettingModel dari data inputan Form UI
      SettingModel settingData = SettingModel(
        idSetting: idSettingTemp.value,
        instansi: instansiController.text.trim(),
        alamatInstansi: alamatInstansiController.text.trim(),
        namaAplikasi: namaAplikasiController.text.trim(),
        logo: logoAplikasiController.text.trim(),
        kabupaten: kabupatenController.text.trim(),
        profinsi: provinsiController.text.trim(),
        iconApp: iconApplikasiController.text.trim(),
        emailNotif: emailNotifController.text.trim(),
        passwordNotif: passwordNotifController.text.toString(),
      );

      // Panggil fungsi eksekusi SQLite di Repository Anda
      await repo.saveOrUpdateSettingApp(settingData);

      // Opsional: Jika Anda ingin AppBar di HomeScreen langsung berubah namanya secara real-time
      // final homeCtrl = Get.find<HomeController>();
      // homeCtrl.namaAplikasi.value = namaAplikasiCtrl.text.trim();
    } catch (e) {
      print("Error di Controller saat simpan setting: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
