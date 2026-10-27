import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance/models/UserModel.dart';
import 'package:myfinance/repository/UserRepository.dart';
import 'package:myfinance/utils/database_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:bcrypt/bcrypt.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class UserSystemController extends GetxController {
  final box = GetStorage();
  var userSystemListRaw = <UserModel>[].obs;

  final Database db = Get.find<DatabaseService>().db;

  final userCodeController = TextEditingController();
  final userNameController = TextEditingController();
  final namaUserController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final fotoController = TextEditingController();
  final supervisorController = false.obs;

  var isPasswordHidden = true.obs;

  // 🔹 FocusNode untuk navigasi form (Enter / Tab)
  final fnUsercode = FocusNode();
  final fnUsername = FocusNode();
  final fnNamaUser = FocusNode();
  final fnEmail = FocusNode();
  final fnPhone = FocusNode();
  final fnPassword = FocusNode();
  final fnFoto = FocusNode();

  // Masukkan ini di dalam Controller Anda (misal: menuCtrl)
  var columnVisibility = <String, bool>{
    'ID User': true,
    'User Name': true,
    'Nama User': true,
    'Email': true,
    'phone': true,
    'address': true,
    'Supervisor': true,
    'Tgl Login': true,
    'Aksi': true,
  }.obs; // Hapus .obs jika menggunakan StatefulWidget biasa

  var isLoading = false.obs;
  var isFormMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataUserSystem();
  }

  Future<void> dataUserSystem() async {
    try {
      isLoading.value = true;
      final repoUserSystem = UserRepository(db);
      final userSystem = await repoUserSystem.getAllUserSystem();
      if (userSystem.isNotEmpty) {
        List<UserModel> items = userSystem
            .map((e) => UserModel.fromMap(e))
            .toList();
        userSystemList.assignAll(items);
      } else {
        userSystemList.clear();
      }
    } catch (e) {
      print('❌ Error saat mengambil data user system: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 1. Tambahkan variabel untuk menampung kata kunci pencarian
  var searchQuery = ''.obs;

  List<UserModel> get userSystemList {
    if (searchQuery.isEmpty) {
      return userSystemListRaw;
    }

    // Filter berdasarkan semua kolom
    return userSystemListRaw.where((user) {
      final query = searchQuery.value.toLowerCase();

      final matchId = user.userCode.toString().contains(query);
      final matchNama = user.namaUser.toString().contains(query);
      final matchUserName = user.username.toString().contains(query);
      // Jika salah satu kolom cocok, kembalikan true
      return matchId || matchNama || matchUserName;
    }).toList();
  }

  /// Isi form dengan data dari baris tabel yang dipilih (mode Update)
  void isiFormUpdate(UserModel user) {
    userCodeController.text = user.userCode.toString();
    userNameController.text = user.username.toString();
    namaUserController.text = user.namaUser.toString();
    // passwordController.text = user.password.toString();
    emailController.text = user.email.toString();
    phoneController.text = user.phone.toString();
    fotoController.text = user.foto.toString();
    supervisorController.value = false;
    isFormMode.value = true;
  }

  void simpanData() async {
    try {
      isLoading.value = true;
      final repoUserSystem = UserRepository(db);

      // 1. Ambil & parse id_menu dari controller jika ada
      String userCode = userCodeController.text.trim();

      var passwodText = passwordController.text.toString();
      if (passwodText.isNotEmpty) {
        //  Kirim passwodText langsung sebagai String
        String hashedPassword = BCrypt.hashpw(passwodText, BCrypt.gensalt());
        passwordController.text = hashedPassword;
      }

      // 2. Siapkan Payload agar tidak terduplikasi di if-else
      final Map<String, dynamic> payload = {
        'code': userCode,
        'username': userNameController.text.trim(),
        'nama_user': namaUserController.text.trim(),
        'password': passwordController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'foto': fotoController.text.trim(),
        'is_supervisor': supervisorController.value ? 1 : 0,
      };

      dynamic userSystemResult;

      // 1. Simpan gambar ke folder internal lebih dulu
      final String? savedImagePath = await saveImageToLocalFolder(userCode);
      if (savedImagePath == null) {
        Get.snackbar("Error", "Gagal menyimpan gambar");
        return;
      } else {
        fotoController.text = savedImagePath;
      }

      // 3. Eksekusi Insert / Update sesuai keberadaan ID
      if (userCodeController.text.isNotEmpty && userCode != '') {
        userSystemResult = await repoUserSystem.updateUserSystem(payload);
      } else {
        // Generate kode user baru sebelum insert
        String newCode = await repoUserSystem.generateUserCode();
        userCodeController.text = newCode;
        payload['code'] = newCode; // Update payload dengan kode baru
        print(payload);
        if (passwordController.text.isEmpty) {
          Get.snackbar("Error", "password tidak boleh kosong");
          isLoading.value = false;
          return;
        } else {
          userSystemResult = await repoUserSystem.insertUserSystem(payload);
        }
      }

      // 🔄 2. RELOAD DATA TABEL DARI DATABASE
      await dataUserSystem(); // <--- Panggil method fetch/get list data kamu di sini

      // 4. Cek hasil kembalian (bisa berupa List dari DB)
      if (userSystemResult != null &&
          (userSystemResult is List && userSystemResult.isNotEmpty)) {
        SnackbarHelper.success("Data User Berhasil Disimpan");

        isFormMode.value = false;
        clearText();
      } else {
        SnackbarHelper.danger("Data User Gagal Disimpan");
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void clearText() {
    userCodeController.clear();
    userNameController.clear();
    passwordController.clear();
    isPasswordHidden.value = true;
    namaUserController.clear();
    emailController.clear();
    phoneController.clear();
    fotoController.clear();
    supervisorController.value = false;
  }

  // ✅ 1. Deklarasikan variabel reaktif untuk menampung bytes gambar
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();

  // ✅ 2. Sesuaikan fungsi pickFotoFile() Anda
  Future<void> pickFotoFile() async {
    // ✅ Menggunakan FilePicker.platform dengan benar
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData:
          true, // Wajib set true agar bytes terisi (terutama di Flutter Web)
    );

    if (result != null && result.files.single.bytes != null) {
      // Simpan byte file ke reaktif state
      selectedImageBytes.value = result.files.single.bytes;

      // Opsional: Isi teks controller dengan nama file
      fotoController.text = result.files.single.name;
    }
  }

  // 📁 Fungsi untuk menyimpan file gambar ke direktori internal aplikasi
  Future<String?> saveImageToLocalFolder(String userCode) async {
    try {
      // 1. Cek apakah ada file byte gambar baru yang dipilih
      if (selectedImageBytes.value == null) {
        return fotoController
            .text; // Kembalikan path lama jika tidak ada gambar baru
      }

      // 2. Dapatkan direktori tempat file .exe berada (Exe Base Directory)
      final String exePath = Platform.resolvedExecutable;
      final String exeDir = p.dirname(exePath);

      // 3. Buat path direktori tujuan: [Exe_Folder]/myfinance/image/
      final Directory targetDir = Directory(
        p.join(exeDir, 'myfinance', 'image'),
      );

      // 4. Pastikan folder /myfinance/image/ dibuat jika belum ada
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 5. Buat path file lengkap (contoh: C:\AppFolder\myfinance\image\USR-2026052601.jpg)
      final String filePath = p.join(targetDir.path, '$userCode.jpg');

      // 6. Simpan/Tulis file byte gambar ke lokasi tersebut
      final File imageFile = File(filePath);
      await imageFile.writeAsBytes(selectedImageBytes.value!);

      // 7. Kembalikan file path lengkap untuk disimpan ke DB SQLite
      return filePath;
    } catch (e) {
      print("Error saving image to exe base directory: $e");
      return null;
    }
  }

  Future<void> deleteUser(
    BuildContext context,
    String userCode,
    String NamaUser,
  ) async {
    // Tampilkan dialog konfirmasi terlebih dahulu
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Hapus User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus user "$NamaUser"?\nTindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Tampilkan progress dialog saat proses berlangsung
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF2C2C34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Menghapus data user...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final repoUser = UserRepository(db);
      final bool success = await repoUser.deleteUserSystem(userCode);

      // Tutup progress dialog
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        await dataUserSystem();
        SnackbarHelper.success('User "$userCode" berhasil dihapus');
      } else {
        SnackbarHelper.danger('Gagal menghapus user "$userCode"');
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      SnackbarHelper.danger('Terjadi kesalahan: $e');
    }
  }
}
