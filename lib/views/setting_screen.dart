// lib/screens/setting_screen.dart

import 'package:flutter/material.dart';
import 'package:myfinance/utils/form_widget.dart';
import 'package:myfinance/controllers/SettingController.dart';
import 'package:get/get.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingController settingCtrl = Get.put(SettingController());

    // KUNCI PERBAIKAN 1: Menghapus Scaffold bawaan agar menyatu dengan Card & Expanded Workspace
    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16.0,
        ), // Padding disesuaikan agar pas di dalam Card Workspace
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. KELOMPOK 1: IDENTITAS APLIKASI & TAMPILAN
            buildCardSection(
              title: 'Identitas & Tampilan Aplikasi',
              icon: Icons.vignette_rounded,
              children: [
                buildTextField(
                  controller: settingCtrl.namaAplikasiController,
                  label: 'Nama Aplikasi',
                  hint: 'Masukkan nama aplikasi utama',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildFilePickerField(
                        controller: settingCtrl.logoAplikasiController,
                        label: 'Path / URL Logo Aplikasi',
                        hint: 'assets/images/logo.png',
                        onPressed: () => settingCtrl.pickLogoFile(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildFilePickerField(
                        controller: settingCtrl.iconApplikasiController,
                        label: 'Icon Aplikasi',
                        hint: 'assets/icons/favicon.ico',
                        onPressed: () => settingCtrl.pickIconFile(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 3. KELOMPOK 2: INFORMASI INSTANSI
            buildCardSection(
              title: 'Profil & Legalitas Instansi',
              icon: Icons.business_rounded,
              children: [
                buildTextField(
                  controller: settingCtrl.instansiController,
                  label: 'Nama Instansi',
                  hint: 'Masukkan nama instansi utama',
                ),
                const SizedBox(height: 16),
                buildTextField(
                  controller: settingCtrl.alamatInstansiController,
                  label: 'Alamat Lengkap Instansi',
                  hint: 'Jl. Pemuda No. 123',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        controller: settingCtrl.kabupatenController,
                        label: 'Kabupaten / Kota',
                        hint: 'Surabaya',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTextField(
                        controller: settingCtrl.provinsiController,
                        label: 'Provinsi',
                        hint: 'Jawa Timur',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 4. KELOMPOK 3: PENGATURAN NOTIFIKASI EMAIL (SMTP)
            buildCardSection(
              title: 'Konfigurasi Email Notifikasi',
              icon: Icons.mail_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        controller: settingCtrl.emailNotifController,
                        label: 'Email Pengirim (SMTP)',
                        hint: 'noreply@instansi.com',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildPasswordField(
                        controller: settingCtrl.passwordNotifController,
                        label: 'Password / App Token Email',
                        hint: '••••••••••••',
                        isObscure: settingCtrl.isPasswordHidden,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 5. ACTION BUTTONS (BATAL & SIMPAN)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: settingCtrl.isLoading.value
                      ? null
                      : () => settingCtrl.updateSettingData(),
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 18,
                    color: Color.fromARGB(255, 45, 46, 45),
                  ),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Color.fromARGB(255, 45, 46, 45),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      78,
                      218,
                      148,
                    ), // Hijau khas tema aplikasi Anda
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
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
