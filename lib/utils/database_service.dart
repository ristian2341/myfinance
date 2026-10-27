import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseService extends GetxService {
  late Database _db;
  Database get db => _db;

  Future<DatabaseService> init() async {
    await _initDatabase();
    return this;
  }

  Future<void> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final folderPath = join(dbPath, 'database');
    final path = join(folderPath, 'my_app_database.db');

    // ✨ TAMBAHKAN BARIS INI UNTUK MENCETAK LOKASI ASLI DI TERMINAL:
    print("====================================================");
    print("DATABASE DI-GENERATE DI SINI: $path");
    print("====================================================");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createDB(db, newVersion);
      },
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    var batch = db.batch();

    // Hapus tabel jika sudah ada (DROP TABLE IF EXISTS)
    // Diurutkan dari tabel relasi (child) ke tabel utama (parent) untuk menghindari Foreign Key constraint
    batch.execute('DROP TABLE IF EXISTS group_menu_detail');
    batch.execute('DROP TABLE IF EXISTS group_menu');
    batch.execute('DROP TABLE IF EXISTS menu_user');
    batch.execute('DROP TABLE IF EXISTS profile');
    batch.execute('DROP TABLE IF EXISTS setting');
    batch.execute('DROP TABLE IF EXISTS menu');
    batch.execute('DROP TABLE IF EXISTS user');

    // TABEL 1: User
    batch.execute('''
      CREATE TABLE IF NOT EXISTS user (
        code TEXT NOT NULL DEFAULT '',
        username TEXT DEFAULT NULL,
        password TEXT DEFAULT NULL,
        email TEXT DEFAULT NULL,
        nama_panggilan TEXT DEFAULT NULL,
        longitudes REAL DEFAULT NULL,
        latitude REAL DEFAULT NULL,
        firebase TEXT DEFAULT NULL,
        developer INTEGER DEFAULT NULL,
        supervisor INTEGER DEFAULT NULL,
        phone TEXT DEFAULT NULL,
        login_at TEXT DEFAULT NULL,
        access_token TEXT DEFAULT NULL,
        verify_code TEXT DEFAULT NULL,
        updated_at TEXT DEFAULT NULL,
        created_at TEXT DEFAULT NULL,
        foto TEXT,
        PRIMARY KEY (code)
      )
    ''');

    // TABEL 2: Profile
    batch.execute('''
      CREATE TABLE IF NOT EXISTS profile (
        code TEXT NOT NULL DEFAULT '',
        user_code TEXT DEFAULT NULL,
        nama_lengkap TEXT DEFAULT NULL,
        whatsapp TEXT DEFAULT NULL,
        alamat TEXT DEFAULT NULL,
        kota TEXT DEFAULT NULL,
        propinsi TEXT DEFAULT NULL,
        facebook TEXT DEFAULT NULL,
        instagram TEXT DEFAULT NULL,
        tiktok TEXT DEFAULT NULL,
        created_at TEXT DEFAULT NULL,
        updated_at TEXT DEFAULT NULL,
        created_by TEXT DEFAULT NULL,
        updated_by TEXT DEFAULT NULL,
        foto TEXT DEFAULT NULL,
        tgl_lahir TEXT DEFAULT NULL,
        jenis_kel TEXT DEFAULT NULL,
        PRIMARY KEY (code),
        FOREIGN KEY (user_code) REFERENCES user (code) ON DELETE CASCADE
      )
    ''');

    // TABEL 3: Menu
    batch.execute('''
      CREATE TABLE IF NOT EXISTS menu (
        id_menu INTEGER NOT NULL DEFAULT 0,
        nama TEXT DEFAULT NULL,
        id_header INTEGER DEFAULT NULL,
        level INTEGER DEFAULT NULL,
        urutan INTEGER DEFAULT NULL,
        url_menu TEXT DEFAULT NULL,
        posisi TEXT DEFAULT NULL,
        `read` INTEGER DEFAULT 0,
        `create` INTEGER DEFAULT 0,
        `update` INTEGER DEFAULT 0,
        `delete` INTEGER DEFAULT 0,
        akses_menu TEXT DEFAULT NULL,
        created_at INTEGER DEFAULT NULL,
        created_by TEXT DEFAULT NULL,
        updated_at INTEGER DEFAULT NULL,
        updated_by TEXT DEFAULT NULL,
        PRIMARY KEY (id_menu)
      )
    ''');

    // TABEL 4: Menu User
    batch.execute('''
      CREATE TABLE IF NOT EXISTS menu_user (
        id_menu_user INTEGER PRIMARY KEY AUTOINCREMENT,
        id_menu INTEGER DEFAULT NULL,
        user_code TEXT DEFAULT NULL,
        `read` INTEGER DEFAULT 0,
        `create` INTEGER DEFAULT 0,
        `update` INTEGER DEFAULT 0,
        `delete` INTEGER DEFAULT 0,
        created_at INTEGER DEFAULT NULL,
        created_by TEXT DEFAULT NULL,
        updated_at INTEGER DEFAULT NULL,
        updated_by TEXT DEFAULT NULL,
        FOREIGN KEY (user_code) REFERENCES user (code) ON DELETE CASCADE,
        FOREIGN KEY (id_menu) REFERENCES menu (id_menu) ON DELETE CASCADE
      )
    ''');

    // ✨ TABEL 5: Setting (Disesuaikan dari skema MySQL Anda ke SQLite)
    batch.execute('''
      CREATE TABLE IF NOT EXISTS setting (
        id_setting INTEGER PRIMARY KEY AUTOINCREMENT,
        instansi TEXT DEFAULT NULL,
        alamat_instansi TEXT DEFAULT NULL,
        kabupaten TEXT DEFAULT NULL,
        profinsi TEXT DEFAULT NULL,
        nama_aplikasi TEXT DEFAULT NULL,
        logo TEXT DEFAULT NULL,
        background TEXT DEFAULT NULL,
        icon TEXT DEFAULT NULL,
        email_notif TEXT DEFAULT NULL,
        password_email TEXT DEFAULT NULL
      )
    ''');

    // TABEL 6: Group Menu
    batch.execute('''
      CREATE TABLE IF NOT EXISTS group_menu (
        id_group_menu INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT DEFAULT NULL,
        keterangan TEXT DEFAULT NULL,
        created_at INTEGER DEFAULT NULL,
        created_by TEXT DEFAULT NULL,
        updated_at INTEGER DEFAULT NULL,
        updated_by TEXT DEFAULT NULL
      )
    ''');

    // TABEL 7: Detail Group Menu
    batch.execute('''
      CREATE TABLE IF NOT EXISTS group_menu_detail (
        id_detail INTEGER PRIMARY KEY AUTOINCREMENT,
        id_group_menu INTEGER DEFAULT NULL,
        id_menu INTEGER DEFAULT NULL,
        `read` INTEGER DEFAULT 0,
        `create` INTEGER DEFAULT 0,
        `update` INTEGER DEFAULT 0,
        `delete` INTEGER DEFAULT 0,
        created_at INTEGER DEFAULT NULL,
        created_by TEXT DEFAULT NULL,
        updated_at INTEGER DEFAULT NULL,
        updated_by TEXT DEFAULT NULL,
        FOREIGN KEY (id_group_menu) REFERENCES group_menu (id_group_menu) ON DELETE CASCADE,
        FOREIGN KEY (id_menu) REFERENCES menu (id_menu) ON DELETE CASCADE
      )
    ''');
    // -------------------------------------------------------
    // INJECT DATA AWAL DEFAULT (Seeding Data Ristian & Menu)
    // -------------------------------------------------------

    // 1. Data User Ristian (Password dibuat 'password' agar sinkron dengan LoginController)
    // 2. Generate hash dengan BCrypt
    final String hashedPassword = BCrypt.hashpw('Tian8116', BCrypt.gensalt());
    batch.insert('user', {
      'code': 'USR-2026052601',
      'username':
          'ristian', // Menggunakan 'admin' agar bisa lolos validasi LoginController Anda
      'password': hashedPassword,
      'email': 'ristian.rehi@gmail.com',
      'nama_panggilan': 'Ristian',
      'longitudes': 112.7521,
      'latitude': -7.2575,
      'firebase': '',
      'developer': 1,
      'supervisor': 0,
      'phone': '08563376207',
      'login_at': DateTime.now().toIso8601String(),
      'access_token': '',
      'verify_code': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'foto': '',
    });

    // 2. Data Profile Ristian
    batch.insert('profile', {
      'code': 'PRF-2026052601',
      'user_code': 'USR-2026052601',
      'nama_lengkap': 'Ristian Eka Hendi Ismawan',
      'whatsapp': '08563376207',
      'alamat': 'Perum. Graha Indraprasta Blok D5 No. 6 Tulangan',
      'kota': 'Sidoarjo',
      'propinsi': 'Jawa Timur',
      'facebook': '',
      'instagram': '',
      'tiktok': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'created_by': 'SYSTEM',
      'updated_by': 'SYSTEM',
      'foto': '',
      'tgl_lahir': '1998-08-15',
      'jenis_kel': 'L',
    });

    // 3. Data Menu Default untuk Dashboard Utama
    batch.insert('menu', {
      'id_menu': 1,
      'nama': 'Dashboard Utama',
      'id_header': 0,
      'level': 1,
      'urutan': 1,
      'url_menu': '/dashboard',
      'posisi': 'main',
      'read': 1,
      'create': 1,
      'update': 1,
      'delete': 1,
    });

    // 4. Hubungkan Menu ke User Ristian (Menu User)
    batch.insert('menu_user', {
      'id_menu': 1,
      'user_code': 'USR-2026052601',
      'read': 1,
      'create': 1,
      'update': 1,
      'delete': 1,
    });

    // ✨ 5. Data Awal untuk Tabel Setting (Sesuai AUTO_INCREMENT=2 / ID awal = 1)
    batch.insert('setting', {
      'id_setting': 1,
      'instansi': 'Rtie Development Corp',
      'alamat_instansi': 'Perum. Graha Indraprasta Blok D5 No. 6 Tulangan',
      'kabupaten': 'Sidoarjo',
      'profinsi': 'Jawa Timur',
      'nama_aplikasi':
          'Finance & Accounting', // Nama ini yang akan dibaca di AppBar HomeScreen Anda
      'logo': '',
      'background': '',
      'icon': '',
      'email_notif': '',
      'password_email': '',
    });

    await batch.commit();
    print("Database dan Tabel Setting Berhasil Dirakit!");
  }
}
