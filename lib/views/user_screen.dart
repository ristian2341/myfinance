import 'package:flutter/material.dart';
import 'package:myfinance/controllers/UserSystemController.dart';
import 'package:get/get.dart';

import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:myfinance/utils/form_widget.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserSystemController userCtrl = Get.put(UserSystemController());
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
              userCtrl.isFormMode.value
                  ? 'Data User System'
                  : 'Master User System',
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
                if (userCtrl.isFormMode.value) {
                  // Tombol BATAL saat di dalam Form
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => userCtrl.isFormMode.value = false,
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
                      userCtrl.clearText();
                      userCtrl.isFormMode.value = true;
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

        // ================= TAMPILAN UTAMA TABEL =================
        body: Obx(() {
          if (userCtrl.isFormMode.value) {
            // ================= TAMPILAN FORM INPUT MENU =================
            return _buildFormInputUser(context, userCtrl);
          } else {
            // ================= TAMPILAN UTAMA TABEL =================
            final Map<String, double> allColumns = {
              'ID User': 0.10,
              'User Name': 0.10,
              'Nama User': 0.22,
              'Email': 0.15,
              'Phone': 0.10,
              'Supervisor': 0.10,
              'Tgl Login': 0.10,
              'Aksi': 0.08,
            };

            final List<String> activeColumnNames = allColumns.keys
                .where((key) => userCtrl.columnVisibility[key] ?? false)
                .toList();

            double totalActivePercentage = activeColumnNames.fold(
              0.0,
              (sum, key) => sum + (allColumns[key] ?? 0.0),
            );

            if (totalActivePercentage == 0.0) totalActivePercentage = 1.0;

            final int columnCount = activeColumnNames.length;
            final bool isDataEmpty = userCtrl.userSystemList.isEmpty
                ? true
                : false;
            final int rowCount =
                1 + (isDataEmpty ? 1 : userCtrl.userSystemList.length);

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
                              userCtrl.searchQuery.value = value,
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
                                    size: 12,
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
                            userCtrl.columnVisibility.keys.map((col) {
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
                                      value: userCtrl.columnVisibility[col],
                                      activeColor: Colors.indigoAccent,
                                      dense: true,
                                      onChanged: (val) {
                                        userCtrl.columnVisibility[col] =
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
                          final user = userCtrl.userSystemList[cellBaris - 1];
                          String teksSel = '';
                          switch (columnName) {
                            case 'ID User':
                              teksSel = user.userCode.toString();
                              break;
                            case 'User Name':
                              teksSel = user.username.toString();
                              break;
                            case 'Nama User':
                              teksSel = user.namaUser.toString();
                              break;
                            case 'Email':
                              teksSel = user.email.toString();
                              break;
                            case 'Phone':
                              teksSel = user.phone.toString();
                              break;
                            case 'Supervisor':
                              teksSel = user.isSupervisor == 1
                                  ? 'Yes'
                                  : 'No';
                              break;
                            default:
                              teksSel = '-';
                              break;
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
                                            userCtrl.isiFormUpdate(user),
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
                                        onTap: () => userCtrl.deleteUser(
                                          context,
                                          user.userCode.toString(),
                                          user.username.toString(),
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
                                  columnName == 'ID User' ||
                                      columnName == 'User Name' ||
                                      columnName == 'Nama User' ||
                                      columnName == 'Email' ||
                                      columnName == 'Phone'
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

  // ================= WIDGET FORM INPUT USER BARU =================
  Widget _buildFormInputUser(
    BuildContext context,
    UserSystemController userCtrl,
  ) {
    final bool isNewUser = userCtrl.userCodeController.text.trim().isEmpty;
    final String cardTitle = isNewUser ? "Form User Baru" : "Form Update User";
    if (!isNewUser) {
      userCtrl.passwordController.text = "";
    }
    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KELOMPOK FORM INPUT INFORMASI AKUN & PROFIL
            buildCardSection(
              title: cardTitle,
              icon: isNewUser
                  ? Icons.person_add_rounded
                  : Icons.manage_accounts_rounded,
              children: [
                // Row 1: User Code (Read-Only saat edit) & Username
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isNewUser) ...[
                      Expanded(
                        flex: 2,
                        child: buildTextField(
                          controller: userCtrl.userCodeController,
                          label: 'Kode User',
                          hint: 'Kode User...',
                          readOnly: true, // User Code / ID biasanya read-only
                          focusNode: userCtrl.fnUsercode,
                          nextFocusNode: userCtrl.fnUsername,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      flex: 2,
                      child: buildCheckbox(
                        label: 'Supervisor',
                        value: userCtrl.supervisorController.value,
                        onChanged: (bool? valueSpv) {
                          if (valueSpv != null) {
                            userCtrl.supervisorController.value = valueSpv;
                          }
                        },
                      ),
                    ),
                    if (isNewUser) ...[
                      const SizedBox(width: 6),
                      const Expanded(
                        flex: 3,
                        child: SizedBox(),
                      ), // Penyeimbang grid
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                // Row 2: Email & Password
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildTextField(
                        controller: userCtrl.userNameController,
                        label: 'Username',
                        hint: 'Masukkan username...',
                        focusNode: userCtrl.fnUsername,
                        nextFocusNode: userCtrl.fnEmail,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: buildPasswordField(
                        controller: userCtrl.passwordController,
                        label: 'Password',
                        isObscure: userCtrl.isPasswordHidden,
                        hint: isNewUser
                            ? 'Masukkan password...'
                            : 'Kosongkan jika tidak diubah',
                        focusNode: userCtrl.fnPassword,
                        nextFocusNode: userCtrl.fnNamaUser,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Row 3: Nama Panggilan & Phone
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildTextField(
                        controller: userCtrl.namaUserController,
                        label: 'Full Name',
                        hint: 'Masukkan Nama Lengkap...',
                        focusNode: userCtrl.fnNamaUser,
                        nextFocusNode: userCtrl.fnEmail,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 1,
                      child: buildTextField(
                        controller: userCtrl.emailController,
                        label: 'Email',
                        hint: 'Masukkan email...',
                        focusNode: userCtrl.fnEmail,
                        nextFocusNode: userCtrl.fnPhone,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 1,
                      child: buildTextField(
                        controller: userCtrl.phoneController,
                        label: 'No. Telepon / Phone',
                        hint: 'Masukkan nomor telepon...',
                        focusNode: userCtrl.fnPhone,
                        nextFocusNode: userCtrl.fnEmail,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Row 4: URL/Path Foto & Tampilan Preview Foto di Bawahnya
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // File Picker Field
                          buildFilePickerField(
                            controller: userCtrl.fotoController,
                            label: 'Foto Profile',
                            hint: 'Masukkan link/path foto...',
                            onPressed: () => userCtrl.pickFotoFile(),
                          ),

                          // Preview Foto Reaktif
                          Obx(() {
                            final bool hasMemoryImage =
                                userCtrl.selectedImageBytes.value != null;
                            final bool hasPathImage = userCtrl
                                .fotoController
                                .text
                                .trim()
                                .isNotEmpty;

                            if (!hasMemoryImage && !hasPathImage) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 320,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: hasMemoryImage
                                          ? Image.memory(
                                              userCtrl
                                                  .selectedImageBytes
                                                  .value!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              userCtrl.fotoController.text,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        'Gagal memuat',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        userCtrl.selectedImageBytes.value =
                                            null;
                                        userCtrl.fotoController.clear();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. ACTION BUTTONS (Batal & Simpan)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => userCtrl.isFormMode.value = false,
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
                    userCtrl.simpanData();
                    userCtrl.isFormMode.value = false;
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
                  style: ButtonStyle(
                    mouseCursor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return SystemMouseCursors.forbidden;
                      }
                      return SystemMouseCursors.click;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.green.shade200;
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.green.shade700;
                      }
                      return const Color(0xFF0BC92B);
                    }),
                    elevation: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return 6.0;
                      }
                      return 3.0;
                    }),
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
