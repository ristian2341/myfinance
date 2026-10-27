import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:myfinance/controllers/MenuAppController.dart';
import 'package:myfinance/utils/form_widget.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MenuAppController menuCtrl = Get.put(MenuAppController());
    double lebarLayar = MediaQuery.of(context).size.width;
    double minLebarTabel = 1100;

    double lebarAktif = (lebarLayar - 32) > minLebarTabel
        ? (lebarLayar - 32)
        : minLebarTabel;

    return SelectionArea(
      child: Scaffold(
        // 🟢 Set latar belakang utama dengan warna gelap netral
        backgroundColor: const Color(0xFF1E1E24),

        // ================= APPBAR DENGAN TOMBOL DINAMIS =================
        appBar: AppBar(
          title: Obx(
            () => Text(
              menuCtrl.isFormMode.value
                  ? 'Input Master Menu Baru'
                  : 'Master Menu & Hak Akses',
              style: const TextStyle(
                color: Color.fromARGB(248, 243, 239, 239),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 71, 71, 73),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Obx(() {
                if (menuCtrl.isFormMode.value) {
                  // Tombol BATAL saat di dalam Form
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => menuCtrl.isFormMode.value = false,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  // Tombol TAMBAH saat di dalam Tabel
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      menuCtrl.clearText();
                      menuCtrl.loadHeaderMenu();
                      menuCtrl.isFormMode.value = true;
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }
              }),
            ),
          ],
        ),

        body: Obx(() {
          if (menuCtrl.isFormMode.value) {
            // ================= TAMPILAN FORM INPUT MENU =================
            return _buildFormInput(context, menuCtrl);
          } else {
            // ================= TAMPILAN UTAMA TABEL =================
            final Map<String, double> allColumns = {
              'ID Menu': 0.08,
              'Nama Menu': 0.22,
              'Header': 0.20,
              'Urutan': 0.06,
              'URL Route': 0.13,
              'Read': 0.06,
              'Create': 0.06,
              'Update': 0.06,
              'Delete': 0.06,
              'Aksi': 0.09,
            };

            final List<String> activeColumnNames = allColumns.keys
                .where((key) => menuCtrl.columnVisibility[key] ?? false)
                .toList();

            double totalActivePercentage = activeColumnNames.fold(
              0.0,
              (sum, key) => sum + (allColumns[key] ?? 0.0),
            );

            if (totalActivePercentage == 0.0) totalActivePercentage = 1.0;

            final int columnCount = activeColumnNames.length;
            final bool isDataEmpty = menuCtrl.menuList.isEmpty ? true : false;
            final int rowCount =
                1 + (isDataEmpty ? 1 : menuCtrl.menuList.length);

            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- COMPONENT INPUT PENCARIAN ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: lebarLayar * 0.5,
                        height: 40,
                        child: TextField(
                          onChanged: (value) =>
                              menuCtrl.searchQuery.value = value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(
                              0xFF2C2C34,
                            ), // Latar gelap field pencarian
                            hintText: 'Cari data menu...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            prefixIcon:
                                TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ).toString().isEmpty
                                ? Icon(
                                    Icons.search,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.5),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.indigoAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        color: const Color(0xFF2C2C34),
                        itemBuilder: (context) =>
                            menuCtrl.columnVisibility.keys.map((col) {
                              return PopupMenuItem(
                                value: col,
                                child: StatefulBuilder(
                                  builder: (context, menuSetState) {
                                    return CheckboxListTile(
                                      title: Text(
                                        col,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      value: menuCtrl.columnVisibility[col],
                                      activeColor: Colors.indigoAccent,
                                      dense: true,
                                      onChanged: (val) {
                                        menuCtrl.columnVisibility[col] =
                                            val ?? false;
                                        menuSetState(() {});
                                      },
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- TABLEVIEW COMPONENT ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF25252D,
                        ), // Background container tabel
                        border: Border.all(color: const Color(0xFF3F3F4C)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TableView.builder(
                        verticalDetails: const ScrollableDetails.vertical(),
                        horizontalDetails: const ScrollableDetails.horizontal(),
                        pinnedRowCount: 1,
                        columnCount: columnCount,
                        rowCount: rowCount,
                        columnBuilder: (int columnIndex) {
                          String columnName = activeColumnNames[columnIndex];
                          double persenStatis = allColumns[columnName] ?? 0.1;

                          double persenProporsional =
                              persenStatis / totalActivePercentage;

                          return TableSpan(
                            extent: FixedTableSpanExtent(
                              lebarAktif * persenProporsional,
                            ),
                          );
                        },
                        rowBuilder: (int rowIndex) => TableSpan(
                          extent: FixedTableSpanExtent(
                            rowIndex == 0 ? 45.0 : 50.0,
                          ),
                        ),
                        cellBuilder: (BuildContext context, TableVicinity vicinity) {
                          final int cellKolom = vicinity.column;
                          final int cellBaris = vicinity.row;
                          final String columnName =
                              activeColumnNames[cellKolom];

                          // 1. HEADER CELL
                          if (cellBaris == 0) {
                            return TableViewCell(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 71, 71, 73),
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey[600]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                alignment:
                                    columnName == 'Nama Menu' ||
                                        columnName == 'URL Route'
                                    ? Alignment.centerLeft
                                    : Alignment.center,
                                child: Text(
                                  columnName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }

                          // 2. EMPTY DATA CELL
                          if (isDataEmpty) {
                            if (cellKolom == 0) {
                              return TableViewCell(
                                columnMergeStart: 0,
                                columnMergeSpan: columnCount,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(
                                      0xFF1E1E24,
                                    ), // Menyelaraskan latar saat data kosong
                                  ),
                                  child: const Text(
                                    'Data Tidak ditemukan',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const TableViewCell(
                              child: SizedBox.shrink(),
                            );
                          }

                          // 3. RENDER DATA CELL
                          final menu = menuCtrl.menuList[cellBaris - 1];
                          String teksSel = '';
                          switch (columnName) {
                            case 'ID Menu':
                              teksSel = menu.idMenu.toString();
                              break;
                            case 'Nama Menu':
                              teksSel = menu.nama;
                              break;
                            case 'Header':
                              teksSel = menu.header != null && menu.header != ''
                                  ? menu.header.toString()
                                  : '-';
                              break;
                            case 'Urutan':
                              teksSel = menu.urutan.toString();
                              break;
                            case 'URL Route':
                              teksSel = menu.urlMenu.toString();
                              break;
                            case 'Read':
                            case 'Create':
                            case 'Update':
                            case 'Delete':
                              // Tampilkan ikon centang/silang untuk kolom boolean
                              final bool val = columnName == 'Read'
                                  ? menu.canRead
                                  : columnName == 'Create'
                                  ? menu.canCreate
                                  : columnName == 'Update'
                                  ? menu.canUpdate
                                  : menu.canDelete;
                              return TableViewCell(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C34),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                      right: BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    val ? Icons.check_circle : Icons.cancel,
                                    size: 16,
                                    color: val
                                        ? Colors.green[400]
                                        : Colors.red[300],
                                  ),
                                ),
                              );
                            default:
                              teksSel = '-';
                          }

                          // 🎨 Kolom Aksi: tampilkan tombol Update & Delete
                          if (columnName == 'Aksi') {
                            return TableViewCell(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C34),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    right: BorderSide(
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ✏️ Tombol Update
                                    Tooltip(
                                      message: 'Edit',
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap: () =>
                                            menuCtrl.isiFormUpdate(menu),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[700],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // 🗑️ Tombol Delete
                                    Tooltip(
                                      message: 'Hapus',
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap: () => menuCtrl.hapusData(
                                          menu.idMenu,
                                          menu.nama,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[700],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // 🎨 SET FONT DI SINI
                          Widget cellContent = Text(
                            teksSel,
                            style: const TextStyle(
                              color: Colors.white, // Warna teks
                              fontSize: 13, // Ukuran font
                              fontWeight: FontWeight
                                  .w400, // Ketebalan font (w400 = Normal, bold = FontWeight.bold)
                              fontFamily:
                                  'Roboto', // (Opsional) Nama font family kustom
                              letterSpacing:
                                  0.3, // (Opsional) Jarak antar huruf
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Agar teks panjang otomatis jadi titik-titik (...)
                            maxLines: 1,
                          );

                          return TableViewCell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2C2C34,
                                ), // Latar sel baris data
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              alignment:
                                  columnName == 'Nama Menu' ||
                                      columnName == 'URL Route' ||
                                      columnName == 'Header'
                                  ? Alignment.centerLeft
                                  : Alignment.center,
                              child: cellContent,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }

  // ================= WIDGET FORM INPUT MENU BARU =================
  Widget _buildFormInput(BuildContext context, MenuAppController menuCtrl) {
    final bool isNewMenu =
        menuCtrl.idMenuController.value == '' ||
        menuCtrl.idMenuController.value.toString().trim().isEmpty;
    final String cardTitle = isNewMenu ? "Form Menu Baru" : "Form Update Menu";

    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KELOMPOK FORM INPUT MENU
            buildCardSection(
              title: cardTitle,
              icon: isNewMenu
                  ? Icons.add_circle_rounded
                  : Icons.edit_note_rounded,
              children: [
                // 1. Jika BUKAN menu baru (!isNewMenu), munculkan field Id Menu
                if (isNewMenu) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: buildTextField(
                          controller: menuCtrl.idMenuController,
                          label: 'Id Menu',
                          hint: 'ID Menu...',
                          readOnly: true, // Id Menu biasanya tidak bisa diedit
                          focusNode: menuCtrl.fnIdMenu,
                          nextFocusNode: menuCtrl.fnNamaMenu,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ), // Penyeimbang col-sm-6
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1, // Ko
                      child: buildTextField(
                        controller: menuCtrl.namaMenuController,
                        label: 'Nama Menu',
                        hint: 'Masukkan nama menu...',
                        focusNode: menuCtrl.fnNamaMenu,
                        nextFocusNode: menuCtrl.fnIdHeader,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1, // Ko
                      child: buildSearchableDropdown(
                        label: "Header Menu",
                        hint: 'Pilih Header Menu.....',
                        // 1. Jika menuCtrl.headerList masih null/kosong saat init, berikan default Map kosong {}
                        items: menuCtrl.headerList,

                        // 2. Kirim variabel RxString dari controller (contoh: menuCtrl.selectedHeader)
                        // Atau jika belum ada variabel RxString di controller, bisa buat terpisah / via controller
                        value: menuCtrl.selectedHeader,

                        // 3. Callback onChanged menerima String? (ID/Key dari menu yang dipilih)
                        onChanged: (val) {
                          menuCtrl.idHeaderController.text = val.toString();
                        },
                        focusNode: menuCtrl.fnIdHeader,
                        nextFocusNode: menuCtrl.fnUrlMenu,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3, // Ko
                      child: buildTextField(
                        controller: menuCtrl.urlMenuController,
                        label: 'Url Route',
                        hint: 'Masukkan nama object form...',
                        focusNode: menuCtrl.fnUrlMenu,
                        nextFocusNode: menuCtrl.fnUrutan,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2, // Ko
                      child: buildTextField(
                        controller: menuCtrl.urutanController,
                        label: 'Urutan',
                        hint: 'Masukkan urutan menu...',
                        focusNode: menuCtrl.fnUrutan,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(flex: 1, child: SizedBox()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            buildCardSection(
              title: "Hak Akses Menu",
              icon: Icons.add_circle_rounded,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1, // Ko
                      child: buildCheckbox(
                        label: "Read",
                        value: menuCtrl.canReadController.value,
                        onChanged: (val) {
                          menuCtrl.canReadController.value = val ?? false;
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 1, // Ko
                      child: buildCheckbox(
                        label: "Write",
                        value: menuCtrl.canCreateController.value,
                        onChanged: (val) {
                          menuCtrl.canCreateController.value = val ?? false;
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 1, // Ko
                      child: buildCheckbox(
                        label: "Delete",
                        value: menuCtrl.canDeleteController.value,
                        onChanged: (val) {
                          menuCtrl.canDeleteController.value = val ?? false;
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 1, // Ko
                      child: buildCheckbox(
                        label: "Update",
                        value: menuCtrl.canUpdateController.value,
                        onChanged: (val) {
                          menuCtrl.canUpdateController.value = val ?? false;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // 2. ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => menuCtrl.isFormMode.value = false,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    menuCtrl.simpanData();
                    menuCtrl.isFormMode.value = false;
                  },
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 20,
                    // Warna ikon mengikuti warna teks tombol (putih)
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors
                          .white, // Teks warna putih agar kontras dengan hijau
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ButtonStyle(
                    // 1. Mouse Cursor Tangan
                    mouseCursor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return SystemMouseCursors.forbidden;
                      }
                      return SystemMouseCursors.click;
                    }),

                    // 2. Efek Hover Warna Background (Normal -> Hijau Utama, Hover -> Hijau Gelap)
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors
                            .green
                            .shade200; // Warna saat loading / disabled
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return Colors
                            .green
                            .shade700; // 💡 Warna saat di-HOVER (Hijau lebih gelap)
                      }
                      return const Color(0xFF0BC92B); // Warna normal
                    }),

                    // 3. Efek Elevasi (Meningkat sedikit saat hover)
                    elevation: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return 6.0; // Naik sedikit saat dipanjat cursor
                      }
                      return 3.0;
                    }),

                    // 4. Border dan Padding
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
