import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance/controllers/LoginController.dart';
import 'package:myfinance/controllers/HomeController.dart';
import 'package:myfinance/models/MenuModel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeCtrl = Get.put(HomeController());
    final LoginController loginCtrl = Get.put(LoginController());

    // Variabel reaktif lokal untuk mengontrol Start Menu
    final RxBool isStartMenuOpen = false.obs;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 47, 129, 65),
      body: Stack(
        children: [
          // =========================================================
          // LEVEL 1: STRUKTUR HALAMAN UTAMA (Main Workspace + Footer)
          // Dibungkus GestureDetector untuk mendeteksi klik di luar menu
          // =========================================================
          GestureDetector(
            behavior: HitTestBehavior
                .translucent, // KUNCI: Deteksi klik di area kosong/transparan
            onTap: () {
              // Jika pengguna klik di luar dan Start Menu sedang terbuka, maka TUTUP
              if (isStartMenuOpen.value) {
                isStartMenuOpen.value = false;
              }
            },
            child: Column(
              children: [
                // ── A. APP BAR UTAMA ─────────────────────────────────
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color.fromARGB(255, 30, 82, 70),
                        Color.fromARGB(255, 30, 100, 71),
                        Color.fromARGB(255, 5, 107, 30),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 78, 74, 74),
                        width: 5,
                      ),
                      right: BorderSide(
                        color: Color.fromARGB(255, 78, 74, 74),
                        width: 5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Obx(
                        () => Text(
                          homeCtrl.namaAplikasi.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 🔥 TARUH DI SINI (Menggantikan CircleAvatar lama Anda):
                      PopupMenuButton<void>(
                        offset: const Offset(0, 44),
                        elevation: 8,
                        padding: EdgeInsets.zero,
                        color: const Color(0xFF1E2429),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFF2C343C),
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color(0xFF3A553E),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF2C343C),
                            child: ClipOval(
                              child: Icon(
                                Icons.person,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<void>(
                            enabled: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 20.0,
                            ),

                            // 🛠️ SOLUSI UTAMA: Bungkus isi menu dengan SizedBox untuk mengatur lebar kustom
                            child: SizedBox(
                              width:
                                  320, // 📐 Sesuaikan angka ini (misal 300, 320, atau 350) sesuai kenyamanan mata Anda
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // =========================================================
                                  // 1. FOTO PROFIL DENGAN DOUBLE BORDER
                                  // =========================================================
                                  Obx(() {
                                    final String avatarUrl =
                                        homeCtrl.fotoUser.value;
                                    final bool hasImage =
                                        avatarUrl.isNotEmpty &&
                                        avatarUrl.startsWith('http');

                                    return CircleAvatar(
                                      radius: 43,
                                      backgroundColor: const Color(0xFF3A553E),
                                      child: CircleAvatar(
                                        radius: 41,
                                        backgroundColor: const Color(
                                          0xFF1E2429,
                                        ),
                                        child: CircleAvatar(
                                          radius: 38,
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            94,
                                            111,
                                            128,
                                          ),
                                          child: hasImage
                                              ? ClipOval(
                                                  child: Image.network(
                                                    avatarUrl,
                                                    width: 76,
                                                    height: 76,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color: Colors.white54,
                                                        ),
                                                  ),
                                                )
                                              : const ClipOval(
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 16),

                                  // DETAIL TEXT USER
                                  Obx(
                                    () => Text(
                                      homeCtrl.namaUser.value,
                                      style: const TextStyle(
                                        color: Color(0xFFECEFF1),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(
                                    () => Text(
                                      homeCtrl.userEmail.value,
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Divider(
                                      color: Colors.white10,
                                      height: 1,
                                    ),
                                  ),

                                  // =========================================================
                                  // 2. AREA ROW TOMBOL AKSI
                                  // =========================================================
                                  Row(
                                    children: [
                                      // TOMBOL PROFILE
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: const Icon(
                                            Icons.badge_outlined,
                                            size: 14,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF3A553E,
                                            ),
                                            foregroundColor: Colors.white60,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          label: const Text(
                                            'Profile',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // TOMBOL CHANGE PASSWORD
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: const Icon(
                                            Icons.lock_outline,
                                            size: 14,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white60,
                                            side: const BorderSide(
                                              color: Colors.white10,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          label: const Text(
                                            'Password',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    child: Divider(
                                      color: Colors.white10,
                                      height: 1,
                                    ),
                                  ),

                                  // =========================================================
                                  // 3. TOMBOL LOGOUT (LEBAR PENUH)
                                  // =========================================================
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        loginCtrl.logout();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white60,
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          77,
                                          69,
                                          71,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.logout_rounded,
                                        size: 15,
                                      ),
                                      label: const Text(
                                        'Log Out / Sign Out',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =============================================================================
                // KOMBINASI SATU KESATUAN: TABBAR + WORKSPACE LAYER (TABBED VIEW)
                // =============================================================================
                Obx(() {
                  // Jika tidak ada tab atau controller belum siap, tampilkan placeholder
                  if (homeCtrl.daftarTabAktif.isEmpty ||
                      homeCtrl.tabController == null) {
                    return Expanded(
                      child: const Center(
                        child: Text(
                          'Silakan klik Start Menu di pojok kiri bawah untuk memilih menu keuangan.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 243, 238, 238),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  // Jika ada data tab, bungkus semuanya ke dalam SATU container terpadu
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 81, 85, 92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 4, 20, 48),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(51, 15, 44, 8),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // ── 1. TAB BAR ANDROID STYLE (Pill / Material You) ──
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A1F26),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: TabBar(
                              controller: homeCtrl.tabController,
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              padding: EdgeInsets.zero,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              splashBorderRadius: BorderRadius.circular(20),
                              indicator: BoxDecoration(
                                color: const Color(
                                  0xFF2ECC71,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF2ECC71,
                                  ).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              labelColor: const Color(0xFF2ECC71),
                              unselectedLabelColor: const Color(0xFF8A99A8),
                              labelStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                              onTap: (index) {
                                homeCtrl.activeTabIndex.value = index;
                              },
                              tabs: List.generate(
                                homeCtrl.daftarTabAktif.length,
                                (index) {
                                  final tab = homeCtrl.daftarTabAktif[index];
                                  final bool isSelected =
                                      homeCtrl.activeTabIndex.value == index;

                                  return Tab(
                                    height: 36,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected
                                                  ? const Color(0xFF2ECC71)
                                                  : const Color(0xFF4A5568),
                                            ),
                                          ),
                                          Text(
                                            tab.nama,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            onTap: () =>
                                                homeCtrl.closeTab(index),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 14,
                                                color: isSelected
                                                    ? const Color(
                                                        0xFF2ECC71,
                                                      ).withOpacity(0.8)
                                                    : const Color(0xFF4A5568),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // ── 2. WORKSPACE (TabBarView) ──
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                bottomRight: Radius.circular(9),
                              ),
                              child: TabBarView(
                                // KUNCI EMAS: Pakai ValueKey dari length agar Flutter tahu kapan harus rebuild total
                                key: ValueKey(homeCtrl.daftarTabAktif.length),
                                controller: homeCtrl.tabController,
                                children: homeCtrl.daftarTabAktif
                                    .map((t) => t.konten)
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // ── D. FOOTER / WINDOWS TASKBAR (Berada Paling Bawah) ──
                Container(
                  height: 48,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF3A553E), Color(0xFF065818)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(66, 59, 58, 58),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Obx(
                          () => IconButton(
                            icon: Icon(
                              isStartMenuOpen.value ? Icons.close : Icons.apps,
                              color: isStartMenuOpen.value
                                  ? Colors.amber
                                  : Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Start Menu',
                            onPressed: () {
                              // Membuka/menutup secara mandiri
                              isStartMenuOpen.value = !isStartMenuOpen.value;
                              homeCtrl.fetchUserMenu(homeCtrl.userCode.value);
                            },
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.white24,
                        width: 20,
                        indent: 12,
                        endIndent: 12,
                      ),
                      const Text(
                        'Ready / Connected to SQLite',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const Spacer(),
                      const SizedBox(width: 12),
                      // 🕒 KOMPONEN WAKTU BERJALAN BARU
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                            () => Text(
                              homeCtrl.namaInstansi.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing:
                                    1.1, // Mencegah teks jam goyang/bergeser saat detik berubah
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Icon(
                            Icons
                                .access_time_filled, // Icon jam/timer pendukung
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Obx(
                            () => Text(
                              homeCtrl.waktuBerjalan.value.isEmpty
                                  ? '--/--/---- --:--:--' // Tampilan sementara saat loading awal
                                  : homeCtrl.waktuBerjalan.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing:
                                    1.1, // Mencegah teks jam goyang/bergeser saat detik berubah
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =========================================================
          // LEVEL 2: COMPONENT WINDOWS START MENU (Mengambang Ke Atas)
          // =========================================================
          Obx(() {
            if (!isStartMenuOpen.value) return const SizedBox.shrink();
            return Positioned(
              bottom: 54,
              left: 10,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  elevation: 16,
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 35, 35, 49),
                  child: Container(
                    width: 450,
                    height: 550,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Column(
                      children: [
                        // ================= HEADER PROFIL USER =================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 14,
                            bottom: 12,
                            left: 16,
                            right: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF034C28),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(11),
                              topRight: Radius.circular(11),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF01297E),
                                      child:
                                          homeCtrl.logoAplikasi.value.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: Image.asset(
                                                homeCtrl.logoAplikasi.value,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      homeCtrl.namaAplikasi.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${homeCtrl.username.value} - ${homeCtrl.userEmail.value}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // ================= FILTER PENCARIAN TERSAMBUNG KE GETX =================
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            left: 12,
                            right: 12,
                            bottom: 4,
                          ),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white10,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              cursorColor: const Color(0xFFD4AF37),
                              // KUNCI: Update nilai reactive di GetX setiap kali user mengetik
                              onChanged: (value) {
                                homeCtrl.kataKunciMenu.value = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Search menu...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 18,
                                ),
                                // Tombol 'X' untuk membersihkan pencarian dengan cepat (opsional)
                                suffixIcon: Obx(
                                  () => homeCtrl.kataKunciMenu.value.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            homeCtrl.kataKunciMenu.value = '';
                                            // Jika menggunakan text editing controller, Anda bisa clear di sini
                                          },
                                          child: const Icon(
                                            Icons.clear_rounded,
                                            color: Colors.white54,
                                            size: 16,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ================= LIST VIEW MENU DENGAN REAKTIF OBX =================
                        Expanded(
                          child: Obx(() {
                            if (homeCtrl.isLoadingMenu.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            // Mengambil daftar header yang sudah ter-filter otomatis oleh GetX
                            final headers = homeCtrl.dapatkanHeaderUtama();

                            if (headers.isEmpty) {
                              return Center(
                                child: Text(
                                  'Menu tidak ditemukan',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              itemCount: headers.length,
                              itemBuilder: (context, index) {
                                final MenuModel headerMenu = headers[index];
                                final List<MenuModel> subMenus = homeCtrl
                                    .dapatkanSubMenu(headerMenu.idMenu);
                                final bool memilikiAnak = subMenus.isNotEmpty;

                                IconData iconHeader;
                                switch (headerMenu.nama.toLowerCase()) {
                                  case 'dashboard':
                                    iconHeader = Icons.dashboard_rounded;
                                    break;
                                  case 'menu':
                                    iconHeader = Icons.widgets_rounded;
                                    break;
                                  case 'setting':
                                    iconHeader = Icons.settings_rounded;
                                    break;
                                  default:
                                    iconHeader = Icons.folder_rounded;
                                }

                                if (memilikiAnak) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: ExpansionTile(
                                        // KUNCI: Menggunakan key unik agar tile merender ulang status expand/collapse nya saat user mencari data
                                        key: ValueKey(
                                          '${headerMenu.idMenu}_${homeCtrl.kataKunciMenu.value}',
                                        ),
                                        // KUNCI: Otomatis terbuka lebar jika user sedang melakukan pencarian text
                                        initiallyExpanded: homeCtrl
                                            .kataKunciMenu
                                            .value
                                            .isNotEmpty,
                                        tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        childrenPadding: const EdgeInsets.only(
                                          left: 16,
                                        ),
                                        collapsedIconColor: Colors.white
                                            .withOpacity(0.4),
                                        iconColor: const Color(0xFFD4AF37),
                                        trailing: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                        ),
                                        leading: Icon(
                                          iconHeader,
                                          color: const Color(0xFFD4AF37),
                                          size: 18,
                                        ),
                                        title: Text(
                                          headerMenu.nama,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        children: subMenus.map((subMenu) {
                                          return ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            hoverColor: Colors.white
                                                .withOpacity(0.06),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 0,
                                                ),
                                            horizontalTitleGap: 8,
                                            leading: const Icon(
                                              Icons.insert_drive_file_rounded,
                                              color: Colors.white54,
                                              size: 14,
                                            ),
                                            title: Text(
                                              subMenu.nama,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            trailing: const Icon(
                                              Icons
                                                  .keyboard_arrow_right_rounded,
                                              color: Colors.white54,
                                              size: 14,
                                            ),
                                            onTap: () {
                                              homeCtrl.openNewTab(
                                                subMenu.nama,
                                                subMenu.urlMenu ?? "submenu",
                                              );
                                              isStartMenuOpen.value = false;
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hoverColor: Colors.white.withOpacity(0.06),
                                    horizontalTitleGap: 12,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    leading: Icon(
                                      iconHeader,
                                      color: const Color(0xFFD4AF37),
                                      size: 18,
                                    ),
                                    title: Text(
                                      headerMenu.nama,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () {
                                      homeCtrl.openNewTab(
                                        headerMenu.nama,
                                        headerMenu.urlMenu ?? "header menu",
                                      );
                                      isStartMenuOpen.value = false;
                                    },
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        const Divider(color: Colors.white24, height: 1),

                        // ================= TOMBOL LOGOUT =================
                        ListTile(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(11),
                              bottomRight: Radius.circular(11),
                            ),
                          ),
                          tileColor: Colors.red.withOpacity(0.1),
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: const Text(
                            'Sign Out / Log Out',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            isStartMenuOpen.value = false;
                            loginCtrl.logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
