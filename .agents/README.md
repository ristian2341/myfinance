# Model Context Protocol (MCP) Setup

Berkas ini berisi konfigurasi **MCP (Model Context Protocol)** untuk proyek **MyFinance**.

## Berkas Konfigurasi
- **[`mcp_config.json`](./mcp_config.json)**: Mendefinisikan daftar server MCP yang dapat dijalankan oleh asisten AI.

---

## 🛠️ Server yang Tersedia

### 1. SQLite MCP (`sqlite`)
- **Package**: `@modelcontextprotocol/server-sqlite`
- **Fungsi**: Memungkinkan AI asisten untuk langsung menjalankan query SELECT, membaca skema tabel (`user`, `menu`, `setting`, dll.), dan menginspeksi database SQLite tanpa perlu membuka GUI DB browser manual.
- **Path Database**: Dikonfigurasi ke `${workspaceFolder}/database/my_app_database.db` (dapat disesuaikan ke path database aktif).

### 2. GitHub MCP (`github`)
- **Package**: `@modelcontextprotocol/server-github`
- **Fungsi**: Mengelola repository GitHub (`ristian2341/myfinance`), membuat issue, membaca pull request, memeriksa log workflow GitHub Actions CI/CD.
- **Konfigurasi Token**:
  Masukkan Personal Access Token (classic atau fine-grained dengan akses repo) di bagian `GITHUB_PERSONAL_ACCESS_TOKEN` pada file `mcp_config.json`.

### 3. Fetch MCP (`fetch`)
- **Package**: `@modelcontextprotocol/server-fetch`
- **Fungsi**: Membaca referensi web, dokumentasi library Flutter/Dart, atau endpoint REST API publik untuk membantu proses coding.

---

## 💡 Cara Menjalankan & Memeriksa di Antigravity IDE

1. **Otomatis**: Antigravity akan membaca konfigurasi di folder `.agents/mcp_config.json`.
2. **Inspeksi Server Aktif**:
   Buka menu **Additional Options (...)** di IDE > pilih **MCP Servers** untuk melihat status koneksi dan daftar tool yang terdaftar.
