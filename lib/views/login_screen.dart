import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance/controllers/LoginController.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi background gradient bergerak lambat secara konstan
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final FocusNode passFocus = FocusNode();
    final FocusNode btnFocus = FocusNode();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            // 1. DYNAMIC MOVING GRADIENT BACKGROUND
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF02341D), // Hijau Gelap Berkelas
                  Color(0xFF034C28), // Hijau Tema Utama
                  Color(0xFF0B6636), // Hijau Terang Aksen
                  Color(0xFF011627), // Midnight Navy
                ],
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
              ),
            ),
            child: child,
          );
        },
        // 2. CONTENT FORM (RESPONSIVE & ADAPTIVE)
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double formWidth = constraints.maxWidth > 600
                    ? 400
                    : constraints.maxWidth;

                return SizedBox(
                  width: formWidth,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // KOTAK UTAMA FORM LOGIN (Diberi margin atas agar muat Logo & Nama Aplikasi)
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        decoration: BoxDecoration(
                          color: const Color(0xFF034C28).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFFFFEE0).withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top:
                                95.0, // Ruang vertikal presisi di bawah Nama Aplikasi
                            left: 32.0,
                            right: 32.0,
                            bottom: 40.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Judul "Login Here"
                              const Center(
                                child: Text(
                                  'Login Here',
                                  style: TextStyle(
                                    color: Color(0xFFFFFEE0),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              TextField(
                                controller: controller.emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Enter Email / Username',
                                  // 2. Mengatur gaya label saat posisi normal (di dalam input)
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  hintText: 'Enter Email / Username',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white60,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFFFFEE0),
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(passFocus);
                                },
                              ),
                              const SizedBox(height: 20),
                              Obx(
                                () => TextField(
                                  focusNode: passFocus,
                                  controller: controller.passwordController,
                                  obscureText:
                                      controller.isPasswordHidden.value,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Enter Password',
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    hintText: 'Enter Password',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 14,
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white60,
                                      ),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFFFFEE0),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordHidden.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white60,
                                      ),
                                      onPressed: () =>
                                          controller.isPasswordHidden.toggle(),
                                    ),
                                  ),
                                  onSubmitted: (_) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(btnFocus);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 3. TOMBOL FORGOT PASSWORD (Rata Kanan & Bersih)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Info',
                                      'Halaman Lupa Password',
                                      backgroundColor: const Color(0xFF02341D),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFFFFFEE0),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // 4. TOMBOL LOGIN GRADASI MODERN & MENARIK
                              Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF2A2A), // Crimson Red
                                        Color(0xFFFF6A00), // Sunset Orange
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFF2A2A,
                                        ).withOpacity(0.35),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    focusNode: btnFocus,
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () => controller.login(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // LOGO UTAMA DAN NAMA APLIKASI (Bersih Tanpa Efek Bayangan/Glow)
                      Positioned(
                        top: 0,
                        child: Column(
                          children: [
                            Obx(() {
                              final String pathLogo =
                                  controller.logoAplikasi.value;
                              ImageProvider gambarSesuaiPath;

                              // Cek apakah path mengarah ke assets internal atau file lokal di PC/Device
                              if (pathLogo.startsWith('assets/')) {
                                gambarSesuaiPath = AssetImage(pathLogo);
                              } else if (pathLogo.isNotEmpty) {
                                // Menggunakan FileImage dari dart:io untuk membaca path file windows (D:\...)
                                gambarSesuaiPath = FileImage(File(pathLogo));
                              } else {
                                // Fallback jika string kosong, arahkan ke asset default Anda
                                gambarSesuaiPath = const AssetImage(
                                  'assets/images/finance_accounting.png',
                                );
                              }

                              return CircleAvatar(
                                radius: 41,
                                backgroundColor: const Color(0xFF01297E),
                                backgroundImage: gambarSesuaiPath,
                                // Menambahkan proteksi jika file lokal ternyata dihapus/rusak secara fisik
                                onBackgroundImageError: (exception, stackTrace) {
                                  print(
                                    'Gagal memuat gambar logo, beralih ke fallback aset: $exception',
                                  );
                                },
                              );
                            }),
                            const SizedBox(height: 12),
                            // Nama Aplikasi Tepat di Bawah Logo
                            //  KODE BARU (Bungkus dengan Obx agar otomatis update saat start)
                            Obx(
                              () => Text(
                                controller.namaAplikasi.value.isEmpty
                                    ? 'Finance & Accounting' // Teks sementara / fallback jika database loading
                                    : controller.namaAplikasi.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
