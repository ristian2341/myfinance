import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfinance/models/GroupMenuModel.dart';
import 'package:myfinance/repository/GroupMenuRepository.dart';
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:myfinance/utils/database_service.dart';

class GroupMenuController extends GetxController {
  final box = GetStorage();

  var isLoading = false.obs;
  var isLoadingDetails = false.obs;

  final Database db = Get.find<DatabaseService>().db;

  // Header Form Controllers
  final codeController = TextEditingController();
  final groupMenuController = TextEditingController();
  final keteranganController = TextEditingController();

  final isFormMode = false.obs;
  final selectAll = false.obs;

  // Master Data (untuk Table View)
  final groupMenus = <GroupMenuModel>[].obs;

  // Detail Data (untuk Form Input Menu & Hak Akses)
  final formMenuDetails = <GroupMenuModel>[].obs;

  // Visibilitas kolom di Master Table
  var columnVisibility = <String, bool>{
    'Code': true,
    'Group Menu': true,
    'Keterangan': true,
    'Aksi': true,
  }.obs;

  // Search filter
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroupMenus();
  }

  @override
  void onClose() {
    codeController.dispose();
    groupMenuController.dispose();
    keteranganController.dispose();
    super.onClose();
  }

  /// Ambil data semua Group Menu untuk tabel utama
  Future<void> loadGroupMenus() async {
    try {
      isLoading.value = true;
      final repoGroupMenu = GroupMenuRepository(db);
      final result = await repoGroupMenu.getAllGroupMenu();
      final parsed = result.map((e) => GroupMenuModel.fromMap(e)).toList();
      groupMenus.assignAll(parsed);
    } catch (e) {
      print('Error saat mengambil data group menu: $e');
      SnackbarHelper.danger("Error loadGroupMenus: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Buka form untuk menambah Group Menu baru
  Future<void> bukaFormTambah() async {
    clearForm();
    await loadMenuForNewForm();
    isFormMode.value = true;
  }

  /// Ambil semua menu dari tabel `menu` untuk form baru (semua belum dicentang)
  Future<void> loadMenuForNewForm() async {
    try {
      isLoadingDetails.value = true;
      final repo = GroupMenuRepository(db);
      final rawMenus = await repo.getAllMenuForDetail();
      final list = rawMenus.map((m) {
        return GroupMenuModel(
          code: '',
          groupMenu: '',
          idMenu: m['id_menu'] is int
              ? m['id_menu']
              : int.tryParse(m['id_menu']?.toString() ?? '0') ?? 0,
          namaMenu: m['nama_menu']?.toString() ?? '',
          isHeader: m['id_header'] == 0 ||
              m['url_menu'] == '#' ||
              m['url_menu'] == '',
          isSelected: false,
          canCreate: false,
          canRead: false,
          canUpdate: false,
          canDelete: false,
          canAll: false,
        );
      }).toList();
      formMenuDetails.assignAll(list);
      selectAll.value = false;
    } catch (e) {
      SnackbarHelper.danger("Gagal memuat list menu: $e");
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Buka form untuk mengedit Group Menu
  Future<void> isiFormUpdate(GroupMenuModel group) async {
    try {
      isLoadingDetails.value = true;
      isFormMode.value = true;

      codeController.text = group.code;
      groupMenuController.text = group.groupMenu;
      keteranganController.text = group.keterangan;

      final repo = GroupMenuRepository(db);
      final int groupId = int.tryParse(group.code) ?? 0;

      // Ambil semua menu master dan detail tersimpan
      final allMenus = await repo.getAllMenuForDetail();
      final savedDetails = await repo.getGroupMenuDetails(groupId);

      // Mapping id_menu yang sudah tersimpan
      final Map<int, Map<String, dynamic>> detailMap = {};
      for (var d in savedDetails) {
        final idMenu = d['id_menu'] is int
            ? d['id_menu'] as int
            : int.tryParse(d['id_menu']?.toString() ?? '0') ?? 0;
        detailMap[idMenu] = d;
      }

      final list = allMenus.map((m) {
        final idMenu = m['id_menu'] is int
            ? m['id_menu'] as int
            : int.tryParse(m['id_menu']?.toString() ?? '0') ?? 0;
        final saved = detailMap[idMenu];
        final bool isSelected = saved != null;

        final bool read = isSelected ? (saved['read'] == 1) : false;
        final bool create = isSelected ? (saved['create'] == 1) : false;
        final bool update = isSelected ? (saved['update'] == 1) : false;
        final bool delete = isSelected ? (saved['delete'] == 1) : false;

        return GroupMenuModel(
          code: group.code,
          groupMenu: group.groupMenu,
          idMenu: idMenu,
          namaMenu: m['nama_menu']?.toString() ?? '',
          isHeader: m['id_header'] == 0 ||
              m['url_menu'] == '#' ||
              m['url_menu'] == '',
          isSelected: isSelected,
          canCreate: create,
          canRead: read,
          canUpdate: update,
          canDelete: delete,
          canAll: isSelected && read && create && update && delete,
        );
      }).toList();

      formMenuDetails.assignAll(list);
      _checkSelectAllState();
    } catch (e) {
      SnackbarHelper.danger("Gagal memuat data edit: $e");
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Toggle Pilih Semua Menu
  void toggleSelectAll(bool val) {
    selectAll.value = val;
    for (var item in formMenuDetails) {
      item.isSelected.value = val;
      if (val) {
        if (!item.canCreate.value &&
            !item.canRead.value &&
            !item.canUpdate.value &&
            !item.canDelete.value) {
          item.canRead.value = true;
        }
      } else {
        item.canCreate.value = false;
        item.canRead.value = false;
        item.canUpdate.value = false;
        item.canDelete.value = false;
        item.canAll.value = false;
      }
    }
  }

  /// Toggle Checkbox Menu (Pilih Menu)
  void toggleMenuSelection(GroupMenuModel item, bool val) {
    item.isSelected.value = val;
    if (val) {
      if (!item.canCreate.value &&
          !item.canRead.value &&
          !item.canUpdate.value &&
          !item.canDelete.value) {
        item.canRead.value = true;
      }
    } else {
      item.canCreate.value = false;
      item.canRead.value = false;
      item.canUpdate.value = false;
      item.canDelete.value = false;
      item.canAll.value = false;
    }
    _checkSelectAllState();
  }

  /// Toggle Hak Akses (C, R, U, D, A)
  void togglePermission(GroupMenuModel item, String perm, bool val) {
    if (perm == 'A') {
      item.canAll.value = val;
      item.canCreate.value = val;
      item.canRead.value = val;
      item.canUpdate.value = val;
      item.canDelete.value = val;
      if (val) item.isSelected.value = true;
    } else if (perm == 'R') {
      item.canRead.value = val;
      if (!val) {
        item.canCreate.value = false;
        item.canUpdate.value = false;
        item.canDelete.value = false;
        item.canAll.value = false;
      } else {
        item.isSelected.value = true;
      }
    } else {
      if (perm == 'C') item.canCreate.value = val;
      if (perm == 'U') item.canUpdate.value = val;
      if (perm == 'D') item.canDelete.value = val;

      if (val) {
        item.canRead.value = true;
        item.isSelected.value = true;
      }
    }

    item.canAll.value = item.canCreate.value &&
        item.canRead.value &&
        item.canUpdate.value &&
        item.canDelete.value;

    _checkSelectAllState();
  }

  void _checkSelectAllState() {
    if (formMenuDetails.isEmpty) {
      selectAll.value = false;
      return;
    }
    selectAll.value = formMenuDetails.every((m) => m.isSelected.value);
  }

  /// Simpan Header dan Detail ke SQLite
  Future<void> simpanData() async {
    final namaGroup = groupMenuController.text.trim();
    if (namaGroup.isEmpty) {
      SnackbarHelper.danger("Nama Group Menu tidak boleh kosong!");
      return;
    }

    try {
      isLoading.value = true;
      final repo = GroupMenuRepository(db);

      final selectedMenus = formMenuDetails.where((m) => m.isSelected.value).map((m) {
        return {
          'id_menu': m.idMenu,
          'read': m.canRead.value ? 1 : 0,
          'create': m.canCreate.value ? 1 : 0,
          'update': m.canUpdate.value ? 1 : 0,
          'delete': m.canDelete.value ? 1 : 0,
        };
      }).toList();

      final int? groupId = codeController.text.trim().isNotEmpty
          ? int.tryParse(codeController.text.trim())
          : null;

      final bool success = await repo.saveGroupMenu(
        idGroupMenu: groupId,
        nama: namaGroup,
        keterangan: keteranganController.text.trim(),
        details: selectedMenus,
      );

      if (success) {
        SnackbarHelper.success("Data Group Menu Berhasil Disimpan");
        isFormMode.value = false;
        clearForm();
        await loadGroupMenus();
      } else {
        SnackbarHelper.danger("Gagal menyimpan data Group Menu.");
      }
    } catch (e) {
      SnackbarHelper.danger("Error simpanData: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    codeController.clear();
    groupMenuController.clear();
    keteranganController.clear();
    formMenuDetails.clear();
    selectAll.value = false;
  }

  /// Filter pencarian di tabel master
  List<GroupMenuModel> get groupMenuList {
    if (searchQuery.isEmpty) {
      return groupMenus;
    }
    final query = searchQuery.value.toLowerCase();
    return groupMenus.where((group) {
      final matchId = group.code.toLowerCase().contains(query);
      final matchNama = group.groupMenu.toLowerCase().contains(query);
      final matchKet = group.keterangan.toLowerCase().contains(query);
      return matchId || matchNama || matchKet;
    }).toList();
  }

  /// Hapus Group Menu
  Future<void> deleteGroupMenu(
    BuildContext context,
    String groupMenuCode,
    String groupName,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text(
              'Hapus Group Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus Group Menu "$groupName"?\nSemua hak akses detail terkait akan ikut terhapus.',
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

    try {
      isLoading.value = true;
      final repo = GroupMenuRepository(db);
      final bool success = await repo.deleteGroupMenu(groupMenuCode);

      if (success) {
        await loadGroupMenus();
        SnackbarHelper.success('Group Menu "$groupName" berhasil dihapus');
      } else {
        SnackbarHelper.danger('Gagal menghapus Group Menu "$groupName"');
      }
    } catch (e) {
      SnackbarHelper.danger('Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
