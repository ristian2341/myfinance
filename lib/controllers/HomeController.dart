import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfinance/models/SettingModel.dart';
import 'package:myfinance/models/MenuModel.dart';
import 'package:myfinance/repository/MenuRepository.dart';
import 'package:myfinance/repository/SettingRepository.dart';
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:myfinance/utils/database_service.dart';
import 'package:intl/intl.dart';
import 'package:myfinance/routers/app_router.dart';

class TabItem {
  final String nama;
  final Widget konten;
  TabItem({required this.nama, required this.konten});
}

// KUNCI UTAMA: Tambahkan mixin "with GetSingleTickerProviderStateMixin" untuk menghidupkan TabController
class HomeController extends GetxController with GetTickerProviderStateMixin {
  final box = GetStorage();

  var username = 'Admin User'.obs;
  var userCode = ''.obs;
  var namaUser = 'Admin User'.obs;
  var isLoadingMenu = false.obs;
  var userEmail = 'Admin User'.obs;
  var listMenu = <MenuModel>[].obs;
  var isDeveloper = 0.obs;
  var isSupervisor = 0.obs;
  var accessToken = ''.obs;
  var fotoUser = ''.obs;

  // Variabel observable untuk komponen Setting
  var namaAplikasi = 'Finance & Accounting'.obs;
  var logoAplikasi = ''.obs;
  var iconApplikasi = ''.obs;
  var namaInstansi = ''.obs;

  var activeTabIndex = 0.obs;
  var waktuBerjalan = ''.obs;
  Timer? _timer;

  var kataKunciMenu = ''.obs;
  var daftarTabAktif = <TabItem>[].obs;

  // Jembatan TabController bawaan Flutter untuk TabBarView
  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    mulaiJamBerjalan();
    loadSetting();

    username.value = box.read('username') ?? 'Admin User 2';
    userCode.value = box.read('userCode') ?? '';
    namaUser.value = box.read('namauser') ?? 'Admin User 1';
    userEmail.value = box.read('userEmail') ?? 'admin@user';
    isDeveloper.value = box.read('developer') ?? 0;
    isSupervisor.value = box.read('supervisor') ?? 0;
    accessToken.value = box.read('accessToken') ?? '';
    fotoUser.value = box.read('userFoto') ?? '';

    if (userCode.value.isNotEmpty) {
      fetchUserMenu(userCode.value);
    }
  }

  void sinkronkanTabController() {
    if (daftarTabAktif.isEmpty) {
      tabController?.dispose();
      tabController = null;
      return;
    }

    tabController?.dispose();
    tabController = TabController(
      length: daftarTabAktif.length,
      vsync: this,
      initialIndex: activeTabIndex.value.clamp(0, daftarTabAktif.length - 1),
    );

    tabController!.addListener(() {
      if (!tabController!.indexIsChanging) {
        activeTabIndex.value = tabController!.index;
      }
    });
  }

  void mulaiJamBerjalan() {
    final String pattern = 'dd/MM/yyyy HH:mm:ss';
    waktuBerjalan.value = DateFormat(pattern).format(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      waktuBerjalan.value = DateFormat(pattern).format(DateTime.now());
    });
  }

  Future<void> fetchUserMenu(String userCode) async {
    try {
      isLoadingMenu.value = true;
      final dbService = Get.find<DatabaseService>();
      final db = dbService.db;
      final repo = MenuRepository(db);

      if (isDeveloper.value == 1) {
        List<MenuModel> userMenus = await repo.getMenuDeveloper();
        listMenu.assignAll(userMenus);
      } else {
        List<MenuModel> userMenus = await repo.getMenuByUserCode(userCode);
        listMenu.assignAll(userMenus);
      }

      if (isDeveloper.value == 1) {
        listMenu.addAll([
          MenuModel(
            idMenu: 9991,
            nama: 'Menu',
            idHeader: 0,
            level: 1,
            urutan: 99,
            urlMenu: 'menu_screen.dart',
            canRead: true,
            canCreate: true,
            canUpdate: true,
            canDelete: true,
          ),
          MenuModel(
            idMenu: 9992,
            nama: 'Setting',
            idHeader: 0,
            level: 1,
            urutan: 100,
            urlMenu: 'setting_screen.dart',
            canRead: true,
            canCreate: true,
            canUpdate: true,
            canDelete: true,
          ),
        ]);
      }
    } catch (e) {
      SnackbarHelper.danger("Error memuat konfigurasi: $e");
    } finally {
      isLoadingMenu.value = false;
    }
  }

  void openNewTab(String menuName, String urlMenu) {
    int indeksSama = daftarTabAktif.indexWhere(
      (tab) => tab.nama.toLowerCase() == menuName.toLowerCase(),
    );

    if (indeksSama != -1) {
      activeTabIndex.value = indeksSama;
      tabController?.animateTo(indeksSama); // Pindahkan halaman TabView
    } else {
      Widget halamanTujuan = AppRouter.dapatkanHalaman(urlMenu.toLowerCase());

      daftarTabAktif.add(TabItem(nama: menuName, konten: halamanTujuan));
      activeTabIndex.value = daftarTabAktif.length - 1;

      // Reset & bangun ulang controller agar mengenali jumlah halaman baru
      sinkronkanTabController();
      tabController?.animateTo(daftarTabAktif.length - 1);
    }
  }

  void closeTab(int index) {
    if (index < 0 || index >= daftarTabAktif.length) return;

    daftarTabAktif.removeAt(index);

    if (daftarTabAktif.isEmpty) {
      tabController?.dispose();
      tabController = null;
      activeTabIndex.value = 0;
      return; // jangan panggil sinkronkanTabController lagi
    }

    if (index < activeTabIndex.value) {
      activeTabIndex.value -= 1;
    } else if (index == activeTabIndex.value &&
        activeTabIndex.value >= daftarTabAktif.length) {
      activeTabIndex.value = daftarTabAktif.length - 1;
    }

    sinkronkanTabController();
  }

  @override
  void onClose() {
    _timer?.cancel();
    tabController
        ?.dispose(); // Hapus sisa alokasi objek animasi saat controller hancur
    super.onClose();
  }

  Future<void> loadSetting() async {
    try {
      final dbService = Get.find<DatabaseService>();
      final db = dbService.db;
      final repoSetting = SettingRepository(db);

      SettingModel? appSetting = await repoSetting.getSettingApp();

      debugPrint(appSetting?.instansi);

      namaAplikasi.value = appSetting?.namaAplikasi ?? 'Finance & Accounting';
      final logoPath = appSetting?.logo;

      logoAplikasi.value = (logoPath != null && logoPath.isNotEmpty)
          ? logoPath
          : 'assets/images/finance_accounting.png';
      iconApplikasi.value = appSetting?.iconApp ?? 'assets/images/app_icon.ico';
      namaInstansi.value = appSetting?.instansi.toString() ?? 'My Finance Corp';
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  List<MenuModel> dapatkanSubMenu(int idHeader) {
    final semuaAnak = listMenu
        .where((menu) => menu.idHeader == idHeader)
        .toList();

    if (kataKunciMenu.value.isEmpty) {
      return semuaAnak;
    }

    return semuaAnak.where((subMenu) {
      return subMenu.nama.toLowerCase().contains(
        kataKunciMenu.value.toLowerCase(),
      );
    }).toList();
  }

  List<MenuModel> dapatkanHeaderUtama() {
    if (kataKunciMenu.value.isEmpty) {
      return listMenu
          .where((menu) => menu.idHeader == 0 || menu.idHeader == null)
          .toList();
    }

    return listMenu.where((menu) {
      bool isHeaderUtama = menu.idHeader == 0 || menu.idHeader == null;
      if (!isHeaderUtama) return false;

      bool namaHeaderCocok = menu.nama.toLowerCase().contains(
        kataKunciMenu.value.toLowerCase(),
      );
      bool adaSubMenuCocok = listMenu.any(
        (sub) =>
            sub.idHeader == menu.idMenu &&
            sub.nama.toLowerCase().contains(kataKunciMenu.value.toLowerCase()),
      );

      return namaHeaderCocok || adaSubMenuCocok;
    }).toList();
  }
}
