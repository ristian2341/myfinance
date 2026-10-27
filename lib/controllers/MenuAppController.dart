import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance/utils/database_service.dart';
import 'package:myfinance/repository/MenuRepository.dart';
import 'package:myfinance/models/MenuModel.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfinance/utils/snackbar_helper.dart';

class MenuAppController extends GetxController {
  final box = GetStorage();
  var menuListRaw = <MenuModel>[].obs;

  final Database db = Get.find<DatabaseService>().db;

  final idMenuController = TextEditingController();
  final namaMenuController = TextEditingController();
  final idHeaderController = TextEditingController();
  final levelController = TextEditingController();
  final urutanController = TextEditingController();
  final urlMenuController = TextEditingController();
  final canReadController = false.obs;
  final canCreateController = false.obs;
  final canUpdateController = false.obs;
  final canDeleteController = false.obs;

  // 🔹 FocusNode untuk navigasi form (Enter / Tab)
  final fnIdMenu = FocusNode();
  final fnNamaMenu = FocusNode();
  final fnIdHeader = FocusNode();
  final fnUrutan = FocusNode();
  final fnUrlMenu = FocusNode();

  var selectedHeader = ''.obs;

  var headerList = <String, String>{}.obs; // Menyimpan {id_menu: nama}

  // Masukkan ini di dalam Controller Anda (misal: menuCtrl)
  var columnVisibility = <String, bool>{
    'ID Menu': true,
    'Nama Menu': true,
    'Header': true,
    'Urutan': true,
    'URL Route': true,
    'Read': true,
    'Create': true,
    'Update': true,
    'Delete': true,
    'Aksi': true,
  }.obs; // Hapus .obs jika menggunakan StatefulWidget biasa

  var isLoading = false.obs;
  var isFormMode = false.obs;

  bool get isLoggedIn => box.read('isLoggedIn') ?? false;

  @override
  void onInit() {
    super.onInit();
    dataMenu();
    loadHeaderMenu();
  }

  // Tambahkan variabel idSetting untuk melacak id data saat ini
  var idSettingTemp = 1.obs; // Default 1 jika data baru awal

  // 1. Tambahkan variabel untuk menampung kata kunci pencarian
  var searchQuery = ''.obs;

  // 2. Buat getter untuk menghasilkan list yang sudah terfilter secara otomatis
  List<MenuModel> get menuList {
    if (searchQuery.isEmpty) {
      return menuListRaw;
    }

    // Filter berdasarkan semua kolom
    return menuListRaw.where((menu) {
      final query = searchQuery.value.toLowerCase();

      final matchId = menu.idMenu.toString().contains(query);
      final matchNama = menu.nama.toLowerCase().contains(query);
      final matchHeader = (menu.header?.toString() ?? '').contains(query);
      final matchUrutan = (menu.urutan?.toString() ?? '').contains(query);
      final matchUrl = (menu.urlMenu ?? '').toLowerCase().contains(query);

      // Jika salah satu kolom cocok, kembalikan true
      return matchId || matchNama || matchHeader || matchUrutan || matchUrl;
    }).toList();
  }

  Future<void> dataMenu() async {
    try {
      isLoading.value = true;
      final repoMenu = MenuRepository(db);
      final menu = await repoMenu.getAllMenu();
      if (menu.isNotEmpty) {
        // 1. Ubah nama variabel lokal penampung (misal: items)
        List<MenuModel> items = menu.map((e) => MenuModel.fromMap(e)).toList();

        // 2. Assign ke RxList milik Controller (this.menuList)
        this.menuList.assignAll(items);
      } else {
        this.menuList.clear(); // Kosongkan list UI jika DB kosong
        clearText();
      }
    } catch (e) {
      print('❌ Error saat mengambil data menu: $e');
    } finally {
      isLoading.value = false; // Pastikan isLoading kembali false
    }
  }

  void clearText() {
    idMenuController.clear();
    namaMenuController.clear();
    idHeaderController.clear();
    levelController.clear();
    urutanController.clear();
    urlMenuController.clear();
    canReadController.value = false;
    canCreateController.value = false;
    canUpdateController.value = false;
    canDeleteController.value = false;
    idSettingTemp.value = 1;
  }

  Future<void> loadHeaderMenu() async {
    try {
      final repoMenu = MenuRepository(db);
      final listMenu = await repoMenu.getHeaderMenu();

      if (listMenu.isNotEmpty) {
        for (var menu in listMenu) {
          headerList[menu.idMenu.toString()] = menu.nama;
        }
      }
    } catch (e) {
      // Handle error jika diperlukan
      print('Error saat mengambil data header menu: $e');
    }
  }

  @override
  void onClose() {
    // Dispose TextEditingController
    idMenuController.dispose();
    namaMenuController.dispose();
    idHeaderController.dispose();
    levelController.dispose();
    urutanController.dispose();
    urlMenuController.dispose();
    // Dispose FocusNode
    fnIdMenu.dispose();
    fnNamaMenu.dispose();
    fnIdHeader.dispose();
    fnUrutan.dispose();
    fnUrlMenu.dispose();
    super.onClose();
  }

  void simpanData() async {
    try {
      isLoading.value = true;
      final repoMenu = MenuRepository(db);

      // 1. Ambil & parse id_menu dari controller jika ada
      int idMenu = int.tryParse(idMenuController.text.trim()) ?? 0;

      // 2. Siapkan Payload agar tidak terduplikasi di if-else
      final Map<String, dynamic> payload = {
        'id_menu': idMenu,
        'nama': namaMenuController.text.trim(),
        'id_header': idHeaderController.text.trim(),
        'level': levelController.text.trim(),
        'urutan': urutanController.text.trim(),
        'url_menu': urlMenuController.text.trim(),
        'read': canReadController.value ? 1 : 0,
        'create': canCreateController.value ? 1 : 0,
        'update': canUpdateController.value ? 1 : 0,
        'delete': canDeleteController.value ? 1 : 0,
      };

      dynamic menuResult;

      // 3. Eksekusi Insert / Update sesuai keberadaan ID
      if (idMenuController.text.isNotEmpty && idMenu > 0) {
        print('🔄 DEBUG: Menjalankan UPDATE Menu...');
        menuResult = await repoMenu.updateMenu(payload);
      } else {
        print('➕ DEBUG: Menjalankan INSERT Menu...');
        menuResult = await repoMenu.insertMenu(payload);
      }

      // 🔄 2. RELOAD DATA TABEL DARI DATABASE
      await dataMenu(); // <--- Panggil method fetch/get list data kamu di sini

      // 4. Cek hasil kembalian (bisa berupa List dari DB)
      if (menuResult != null && (menuResult is List && menuResult.isNotEmpty)) {
        // Mapping data hasil dari Database ke Model
        // List<MenuModel> updatedList = (menuResult as List)
        //     .map((e) => MenuModel.fromMap(e))
        //     .toList();

        // Assign ke RxList utama milik Controller/State (Ganti 'menuListRx' dengan nama variabel RxList kamu)
        // menuListRx.assignAll(updatedList);

        SnackbarHelper.success("Data Menu Berhasil Disimpan");

        isFormMode.value = false;
        clearText();
      } else {
        SnackbarHelper.danger(
          "Gagal menyimpan data menu (tidak ada respon dari database)",
        );
      }
    } catch (e) {
      SnackbarHelper.danger("Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Isi form dengan data dari baris tabel yang dipilih (mode Update)
  void isiFormUpdate(MenuModel menu) {
    idMenuController.text = menu.idMenu.toString();
    namaMenuController.text = menu.nama;
    idHeaderController.text = (menu.idHeader ?? 0).toString();
    levelController.text = (menu.level ?? 0).toString();
    urutanController.text = (menu.urutan ?? 0).toString();
    urlMenuController.text = menu.urlMenu ?? '';
    selectedHeader.value = (menu.idHeader ?? 0).toString();
    canReadController.value = menu.canRead;
    canCreateController.value = menu.canCreate;
    canUpdateController.value = menu.canUpdate;
    canDeleteController.value = menu.canDelete;
    loadHeaderMenu();
    isFormMode.value = true;
  }

  /// Konfirmasi lalu hapus menu
  Future<void> hapusData(int idMenu, String namaMenu) async {
    final bool? konfirmasi = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus menu [ $namaMenu ] ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      isLoading.value = true;
      final repoMenu = MenuRepository(db);
      final bool berhasil = await repoMenu.deleteMenu(idMenu);
      if (berhasil) {
        await dataMenu();
        SnackbarHelper.success("Menu berhasil dihapus");
      } else {
        SnackbarHelper.danger('Data tidak ditemukan atau sudah dihapus');
      }
    } catch (e) {
      SnackbarHelper.danger('Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
