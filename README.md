# MyFinance

![CI Pipeline](https://github.com/ristian2341/myfinance/actions/workflows/ci.yml/badge.svg)
![CD & Release Pipeline](https://github.com/ristian2341/myfinance/actions/workflows/cd.yml/badge.svg)

Aplikasi Pencatatan Keuangan berbasis Flutter (Android & Windows Desktop).

---

## 🚀 CI/CD Pipeline & GitHub Actions

Proyek ini telah dikonfigurasi dengan pipeline CI/CD otomatis menggunakan GitHub Actions:

### 1. Continuous Integration (`ci.yml`)
- **Trigger**: Setiap `push` dan `pull_request` pada branch `main` atau `master`.
- **Tugas**:
  - Validasi dependensi (`flutter pub get`).
  - Analisis kode statis (`flutter analyze`).
  - Pengujian unit test otomatis (`flutter test`).
  - Validasi build APK debug (`flutter build apk --debug`).

### 2. Continuous Delivery & Release (`cd.yml`)
- **Trigger**:
  - Push tag git versi baru (contoh: `v1.0.0`, `git push origin v1.0.0`).
  - Manual trigger via menu GitHub Actions (**Workflow Dispatch**).
- **Hasil Build (Artifacts)**:
  - **Android APK**: `myfinance-release.apk`
  - **Android App Bundle**: `myfinance-release.aab`
  - **Windows Desktop**: `myfinance-windows-x64.zip`
- **GitHub Release**: Mengunggah semua artefak build secara otomatis ke halaman GitHub Releases.

---

## 🛠️ Cara Trigger Rilis Otomatis

Untuk merilis versi baru dan membuat installer otomatis:
```bash
git tag v1.0.0
git push origin v1.0.0
```
Atau jalankan secara manual melalui tab **Actions** > **CD & Release Pipeline** > **Run workflow** di GitHub.

