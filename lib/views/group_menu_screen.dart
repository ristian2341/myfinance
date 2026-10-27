import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance/controllers/GroupMenuController.dart';

import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:myfinance/utils/form_widget.dart';

class GroupMenuScreen extends StatelessWidget {
  const GroupMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupMenuController groupMenuCtrl = Get.put(GroupMenuController());

    return SelectionArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E24),
        // ================= APPBAR DENGAN TOMBOL DINAMIS =================
        appBar: AppBar(
          title: Obx(
            () => Text(
              groupMenuCtrl.isFormMode.value
                  ? (groupMenuCtrl.codeController.text.trim().isEmpty
                      ? 'Input Group Menu Baru'
                      : 'Update Group Menu')
                  : 'Master Group Menu',
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
                if (groupMenuCtrl.isFormMode.value) {
                  // Tombol BATAL saat di dalam Form
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => groupMenuCtrl.isFormMode.value = false,
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
                      groupMenuCtrl.bukaFormTambah();
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

        body: SafeArea(
          child: Column(
            children: [
              Obx(() {
                if (groupMenuCtrl.isFormMode.value) {
                  // ================= TAMPILAN FORM INPUT HEADER & DETAIL =================
                  return Expanded(
                    child: _buildFormInput(context, groupMenuCtrl),
                  );
                } else {
                  // ================= TAMPILAN TABEL MASTER =================
                  return Expanded(
                    child: _buildChecklistTable(context, groupMenuCtrl),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET MASTER CHECKLIST TABLE =================
  Widget _buildChecklistTable(
    BuildContext context,
    GroupMenuController groupMenuCtrl,
  ) {
    final Map<String, double> allColumns = {
      'Code': 0.15,
      'Group Menu': 0.35,
      'Keterangan': 0.35,
      'Aksi': 0.15,
    };

    final List<String> activeColumnNames = allColumns.keys
        .where((key) => groupMenuCtrl.columnVisibility[key] ?? false)
        .toList();

    double totalActivePercentage = activeColumnNames.fold(
      0.0,
      (sum, key) => sum + (allColumns[key] ?? 0.0),
    );

    if (totalActivePercentage == 0.0) totalActivePercentage = 1.0;

    return Obx(() {
      if (groupMenuCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.indigo),
        );
      }

      final groupMenus = groupMenuCtrl.groupMenuList;

      double lebarLayar = MediaQuery.of(context).size.width;
      double minLebarTabel = 900;
      double lebarAktif = (lebarLayar - 32) > minLebarTabel
          ? (lebarLayar - 32)
          : minLebarTabel;

      final int columnCount = activeColumnNames.length;
      final bool isDataEmpty = groupMenus.isEmpty;
      final int rowCount = 1 + (isDataEmpty ? 1 : groupMenus.length);

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
                  width: lebarLayar * 0.4 > 250 ? lebarLayar * 0.4 : 250,
                  height: 40,
                  child: TextField(
                    onChanged: (value) =>
                        groupMenuCtrl.searchQuery.value = value,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2C2C34),
                      hintText: 'Cari data group menu...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
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
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  color: const Color(0xFF2C2C34),
                  itemBuilder: (context) =>
                      groupMenuCtrl.columnVisibility.keys.map((col) {
                    return PopupMenuItem(
                      value: col,
                      child: StatefulBuilder(
                        builder: (context, menuSetState) {
                          return CheckboxListTile(
                            title: Text(
                              col,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: groupMenuCtrl.columnVisibility[col],
                            activeColor: Colors.indigoAccent,
                            dense: true,
                            onChanged: (val) {
                              groupMenuCtrl.columnVisibility[col] =
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
                  color: const Color(0xFF25252D),
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
                    extent: FixedTableSpanExtent(rowIndex == 0 ? 45.0 : 50.0),
                  ),
                  cellBuilder: (BuildContext context, TableVicinity vicinity) {
                    final int cellKolom = vicinity.column;
                    final int cellBaris = vicinity.row;
                    final String columnName = activeColumnNames[cellKolom];

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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
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
                              color: Color(0xFF1E1E24),
                            ),
                            child: const Text(
                              'Data Group Menu Belum Ada',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        );
                      }
                      return const TableViewCell(child: SizedBox.shrink());
                    }

                    // 3. RENDER DATA CELL
                    final group = groupMenus[cellBaris - 1];
                    String teksSel = '';
                    switch (columnName) {
                      case 'Code':
                        teksSel = group.code.toString();
                        break;
                      case 'Group Menu':
                        teksSel = group.groupMenu.toString();
                        break;
                      case 'Keterangan':
                        teksSel = group.keterangan.isNotEmpty
                            ? group.keterangan
                            : '-';
                        break;
                      default:
                        teksSel = '-';
                        break;
                    }

                    // Kolom Aksi: Update & Delete
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
                              // ✏️ Tombol Edit
                              Tooltip(
                                message: 'Edit',
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () =>
                                      groupMenuCtrl.isiFormUpdate(group),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[700],
                                      borderRadius: BorderRadius.circular(6),
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
                                  onTap: () => groupMenuCtrl.deleteGroupMenu(
                                    context,
                                    group.code.toString(),
                                    group.groupMenu.toString(),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[700],
                                      borderRadius: BorderRadius.circular(6),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: columnName == 'Aksi'
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: Text(
                          teksSel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ================= WIDGET FORM INPUT HEADER & DETAIL =================
  Widget _buildFormInput(
    BuildContext context,
    GroupMenuController groupMenuCtrl,
  ) {
    final bool isNewMenu =
        groupMenuCtrl.codeController.text.trim().isEmpty;
    final String cardTitle = isNewMenu
        ? "Form Header Group Menu Baru"
        : "Form Header Update Group Menu";

    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KELOMPOK HEADER GROUP MENU
            buildCardSection(
              title: cardTitle,
              icon: isNewMenu
                  ? Icons.add_circle_rounded
                  : Icons.edit_note_rounded,
              children: [
                if (!isNewMenu) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: buildTextField(
                          controller: groupMenuCtrl.codeController,
                          label: 'Id Group Menu',
                          hint: 'ID Group Menu...',
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(flex: 1, child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildTextField(
                        controller: groupMenuCtrl.groupMenuController,
                        label: 'Nama Group Menu *',
                        hint: 'Masukkan nama group menu (contoh: Administrator, Kasir)...',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: buildTextField(
                        controller: groupMenuCtrl.keteranganController,
                        label: 'Keterangan',
                        hint: 'Keterangan atau deskripsi group menu...',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. KELOMPOK DETAIL MENU & HAK AKSES
            buildCardSection(
              title: "Daftar Menu & Hak Akses",
              icon: Icons.checklist_rounded,
              children: [
                buildMenuListTable(groupMenuCtrl),
              ],
            ),
            const SizedBox(height: 18),

            // 3. ACTION BUTTONS (BATAL & SIMPAN)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => groupMenuCtrl.isFormMode.value = false,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
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
                    groupMenuCtrl.simpanData();
                  },
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BC92B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET TABEL DETAIL MENU DENGAN CHECKBOX =================
  Widget buildMenuListTable(GroupMenuController groupMenuCtrl) {
    return Obx(() {
      // 1. CEK LOADING STATE
      if (groupMenuCtrl.isLoadingDetails.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: Colors.indigo),
          ),
        );
      }

      final details = groupMenuCtrl.formMenuDetails;

      if (details.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              "Data menu belum tersedia di database.",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF25252D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3F3F4C)),
        ),
        child: Column(
          children: [
            // HEADER BAR TABEL DETAIL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 60, 60, 66),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  // Checkbox Pilih Semua Menu
                  Obx(
                    () => SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: groupMenuCtrl.selectAll.value,
                        activeColor: Colors.indigoAccent,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) =>
                            groupMenuCtrl.toggleSelectAll(val ?? false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Pilih Semua",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "ID & NAMA MENU",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Kolom Hak Akses Label C, R, U, D, A
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            "C",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            "R",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            "U",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            "D",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            "A",
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // DAFTAR BARIS MENU
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, thickness: 0.8, color: Colors.grey.shade800),
              itemBuilder: (context, index) {
                final item = details[index];
                final isHeader = item.isHeader;

                return Obx(() {
                  final isChecked = item.isSelected.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: isChecked
                        ? Colors.indigo.withOpacity(0.12)
                        : (isHeader
                            ? Colors.white.withOpacity(0.04)
                            : Colors.transparent),
                    child: Row(
                      children: [
                        // 1. Checkbox Centang Menu yang Dipilih
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: item.isSelected.value,
                            activeColor: Colors.indigoAccent,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) => groupMenuCtrl
                                .toggleMenuSelection(item, val ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 2. Badge ID Menu
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF32323E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            "#${item.idMenu}",
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 3. Nama Menu
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: isHeader ? 0.0 : 16.0,
                            ),
                            child: Row(
                              children: [
                                if (isHeader)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.folder_outlined,
                                      size: 16,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                Flexible(
                                  child: Text(
                                    item.namaMenu,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isHeader
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isChecked
                                          ? Colors.white
                                          : (isHeader
                                              ? Colors.white70
                                              : Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 4. Checkbox Hak Akses (C, R, U, D, A)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPermCheckbox(
                              item.canCreate,
                              (val) => groupMenuCtrl.togglePermission(
                                  item, 'C', val),
                            ),
                            _buildPermCheckbox(
                              item.canRead,
                              (val) => groupMenuCtrl.togglePermission(
                                  item, 'R', val),
                            ),
                            _buildPermCheckbox(
                              item.canUpdate,
                              (val) => groupMenuCtrl.togglePermission(
                                  item, 'U', val),
                            ),
                            _buildPermCheckbox(
                              item.canDelete,
                              (val) => groupMenuCtrl.togglePermission(
                                  item, 'D', val),
                            ),
                            _buildPermCheckbox(
                              item.canAll,
                              (val) => groupMenuCtrl.togglePermission(
                                  item, 'A', val),
                              activeColor: Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ],
        ),
      );
    });
  }

  // Sub-widget Checkbox Hak Akses
  Widget _buildPermCheckbox(
    RxBool rxVal,
    Function(bool) onChanged, {
    Color activeColor = Colors.indigoAccent,
  }) {
    return SizedBox(
      width: 44,
      child: Center(
        child: Obx(
          () => SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: rxVal.value,
              activeColor: activeColor,
              side: const BorderSide(color: Colors.white38, width: 1),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) => onChanged(val ?? false),
            ),
          ),
        ),
      ),
    );
  }
}
