import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

/// 🔹 TextField umum
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool readOnly = false,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
  TextInputAction textInputAction = TextInputAction.next,
  ValueChanged<String>? onSubmitted,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: (value) {
        if (onSubmitted != null) onSubmitted(value);
        if (nextFocusNode != null) {
          nextFocusNode.requestFocus();
        }
      },
      // ✅ Enter & Tab pindah ke field berikutnya
      onEditingComplete: () {
        if (nextFocusNode != null) {
          nextFocusNode.requestFocus();
        } else {
          focusNode?.unfocus();
        }
      },
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label, // ✅ label masuk ke border
        labelStyle: const TextStyle(
          color: Color.fromARGB(136, 7, 7, 7), // ✅ label gelap
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color.fromARGB(31, 44, 43, 43), // hint lebih pudar
        ),
        filled: true,
        fillColor: Colors.grey.shade300,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.5,
          ), // ✅ border gelap saat idle
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.black26,
            width: 2,
          ), // ✅ border lebih tebal saat fokus
        ),
      ),
    ),
  );
}

/// 🔹 TextField dengan Password (pakai RxBool agar bisa toggle)
Widget buildPasswordField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required RxBool isObscure, // ✅ ubah jadi RxBool
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
  TextInputAction textInputAction = TextInputAction.next,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => TextField(
            controller: controller,
            obscureText: isObscure.value,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onSubmitted: (_) {
              if (nextFocusNode != null) {
                nextFocusNode.requestFocus();
              } else {
                focusNode?.unfocus();
              }
            },
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ), // ✅ pakai .value
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26),
              filled: true,
              fillColor: Colors.grey.shade300,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black45, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure.value ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => isObscure.value = !isObscure.value,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// 🔹 Dropdown (pakai Map key=>value)
Widget buildDropdownRx({
  required String label,
  required String hint,
  required Map<String, String> items,
  required RxString value,
  Function(String?)? onChanged,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Obx(() {
          // ✅ cek apakah value ada di items
          String? currentValue =
              items.keys.contains(value.value) && value.value.isNotEmpty
              ? value.value
              : null;

          return DropdownButtonFormField<String>(
            isExpanded: true,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 14,
              ),
            ),
            hint: Text(hint),
            value: currentValue, // ✅ kalau tidak valid → null
            items: items.entries
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
            onChanged: (val) {
              value.value = val ?? '';
              if (onChanged != null) onChanged(val);
              // ✅ Setelah pilih → pindah ke field berikutnya
              if (nextFocusNode != null) nextFocusNode.requestFocus();
            },
          );
        }),
      ],
    ),
  );
}

/// 🔹 Select2 Searchable Dropdown (pakai package dropdown_search)
Widget buildSearchableDropdown({
  required String label,
  required String hint,
  required Map<String, String> items,
  required RxString value,
  Function(String?)? onChanged,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Obx(() {
      String? currentKey =
          items.keys.contains(value.value) && value.value.isNotEmpty
          ? value.value
          : null;

      // ✅ BUNGKUS DENGAN WIDGET FOCUS UNTUK MENGELOLA focusNode
      return Focus(
        focusNode: focusNode,
        child: DropdownSearch<String>(
          items: (filter, _) {
            final filtered = items.entries
                .where(
                  (e) =>
                      filter.isEmpty ||
                      e.value.toLowerCase().contains(filter.toLowerCase()),
                )
                .map((e) => e.key)
                .toList();
            return filtered;
          },
          itemAsString: (key) => items[key] ?? key,
          selectedItem: currentKey,
          onChanged: (val) {
            value.value = val ?? '';
            if (onChanged != null) onChanged(val);
            if (nextFocusNode != null) nextFocusNode.requestFocus();
          },
          decoratorProps: DropDownDecoratorProps(
            // ❌ HAPUS focusNode dari sini!
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: Color.fromARGB(136, 7, 7, 7),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Color.fromARGB(31, 44, 43, 43)),
              filled: true,
              fillColor: Colors.grey.shade300,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black26, width: 2),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            menuProps: MenuProps(
              borderRadius: BorderRadius.circular(10),
              elevation: 6,
            ),
            fit: FlexFit.loose,
            constraints: const BoxConstraints(maxHeight: 300),
            itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
              selected: isSelected,
              selectedColor: Colors.orange[900],
              title: Text(
                items[item] ?? item,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.orange[900] : Colors.black87,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Colors.orange[900], size: 18)
                  : null,
            ),
          ),
        ),
      );
    }),
  );
}

/// 🔹 Checkbox
Widget buildCheckbox({
  required String label,
  required bool value,
  required Function(bool?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      // 💡 Saat seluruh area (termasuk label) di-klik, panggil onChanged dengan nilai sebaliknya
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Agar area klik tidak melebar berlebihan
          children: [
            Checkbox(value: value, onChanged: onChanged),
            const SizedBox(width: 4), // Jarak kecil antara box & text
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 🔹 OptionBox (Radio Button Group)
Widget buildOptionBox({
  required String label,
  required Map<String, String> options,
  required String groupValue,
  required Function(String?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.entries.map((entry) {
            return GestureDetector(
              onTap: () => onChanged(entry.key), // ✅ klik label juga bisa pilih
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: entry.key,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: Colors.black, // warna bulat hitam
                  ),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

Widget buildDateField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool readOnly = true,
  required BuildContext context,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
}) {
  DateTime initialDate = DateTime.now();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: readOnly, // ✅ supaya hanya bisa lewat picker
          focusNode: focusNode,
          onTap: () async {
            if (controller.text.isNotEmpty) {
              try {
                // Sesuai dengan format yang Anda gunakan di aplikasi ini (dd-MM-yyyy)
                initialDate = DateFormat("dd-MM-yyyy").parse(controller.text);
              } catch (_) {
                initialDate = DateTime.now(); // fallback jika parse gagal
              }
            }

            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate:
                  initialDate, // ✅ SEKARANG DIUBAH: Menggunakan variabel initialDate agar tidak error warning lagi
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              // ✅ Format tanggal ke dd-MM-yyyy dan masukkan ke controller
              String formattedDate = DateFormat(
                "dd-MM-yyyy",
              ).format(pickedDate);
              controller.text = formattedDate;
              // ✅ Setelah pilih tanggal → pindah ke field berikutnya
              if (nextFocusNode != null) nextFocusNode.requestFocus();
            }
          },
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color.fromARGB(31, 44, 43, 43)),
            filled: true,
            fillColor: Colors.grey.shade300,
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Colors.black54,
              size: 18,
            ), // Icon kalender pemanis
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black26, width: 2),
            ),
          ),
        ),
      ],
    ),
  );
}

/// ✅ Tombol Save (Hijau)
Widget buildSaveButton({
  Future<void> Function()? onPressed, // ⬅️ nullable
  required String label,
}) {
  final isLoading = false.obs;

  return Obx(
    () => ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[900],
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: (onPressed == null || isLoading.value)
          ? null // ⛔️ disabled jika kosong atau sedang loading
          : () async {
              try {
                isLoading.value = true;
                await onPressed(); // ⬅️ aman karena sudah dicek null
              } finally {
                isLoading.value = false;
              }
            },
      icon: isLoading.value
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.save, color: Colors.white),
      label: const Text(
        'Save',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ),
  );
}

/// ✅ Tombol Update (Oranye)
Widget buildUpdateButton({
  required Future<void> Function() onPressed,
  required String label,
}) {
  final isLoading = false.obs;

  return Obx(
    () => ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: isLoading.value
          ? null
          : () async {
              try {
                isLoading.value = true;
                await onPressed();
              } finally {
                isLoading.value = false;
              }
            },
      icon: isLoading.value
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.update, color: Colors.white),
      label: Text(
        isLoading.value ? "Updating..." : label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

/// ✅ Tombol Delete (Merah)
Widget buildDeleteButton({
  required Future<void> Function() onPressed,
  required String label,
}) {
  final isLoading = false.obs;

  return Obx(
    () => ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: isLoading.value
          ? null
          : () async {
              bool? confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text(
                    "Apakah Anda yakin ingin menghapus data ini?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text("Hapus"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  isLoading.value = true;
                  await onPressed();
                } finally {
                  isLoading.value = false;
                }
              }
            },
      icon: isLoading.value
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.delete, color: Colors.white),
      label: Text(
        isLoading.value ? "Deleting..." : label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget listTileItem({
  required IconData icon,
  required String title,
  String subtitle = '',
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.orangeAccent),
    title: Text(title),
    subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
    trailing: Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  );
}

Widget sectionCard({required String title, required List<Widget> children}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    ),
  );
}

Widget buildTextAreaField({
  required TextEditingController controller,
  required String label,
  bool readOnly = false,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,
      focusNode: focusNode,
      maxLines: 6,
      // TextArea: Enter untuk newline, Tab untuk pindah field
      onEditingComplete: () {
        if (nextFocusNode != null) nextFocusNode.requestFocus();
      },
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true, // 🔹 agar label sejajar atas dengan area teks
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.grey.shade300,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black45, width: 2),
        ),
      ),
    ),
  );
}

// Widget Reusable untuk pembungkus Card Kelompok/Section Form
Widget buildCardSection({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color.fromARGB(
        255,
        219,
        221,
        221,
      ), // Kontras warna card agak terang dibanding background body
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color.fromARGB(255, 70, 52, 52).withOpacity(0.05),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 68, 67, 67),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(color: Color.fromARGB(31, 170, 156, 156), height: 1),
        ),

        // KUNCI PERBAIKAN 2: Menggabungkan list children inputan ke dalam tata letak Column utama Card!
        ...children,
      ],
    ),
  );
}

Widget buildFilePickerField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required VoidCallback onPressed,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: true, // User tidak mengetik manual, melainkan memilih file
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.folder_open_rounded),
            onPressed: onPressed,
            tooltip: 'Pilih File',
          ),
        ),
      ),
    ],
  );
}
