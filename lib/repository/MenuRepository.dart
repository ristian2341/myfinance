import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✨ TAMBAHKAN BARIS INI:
export 'package:sqflite_common_ffi/sqflite_ffi.dart' show Database;
import 'package:myfinance/models/MenuModel.dart';
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class MenuRepository {
  final Database _db; // Sekarang kelas 'Database' sudah dikenali dengan aman

  MenuRepository(this._db);

  Future<List<MenuModel>> getMenuByUserCode(String userCode) async {
    try {
      // cek user apakah develooper jika ya tampil semua menu //

      // Ambil hak akses CRUD langsung dari tabel menu_user (mu)
      final List<Map<String, dynamic>> maps = await _db.rawQuery(
        '''
        SELECT 
          m.id_menu, 
          m.nama, 
          m.id_header, 
          m.level, 
          m.urutan, 
          m.url_menu,
          mu.`read`, 
          mu.`create`, 
          mu.`update`, 
          mu.`delete`
        FROM menu_user mu
        JOIN menu m ON mu.id_menu = m.id_menu
        WHERE mu.user_code = ? 
        ORDER BY m.urutan ASC
      ''',
        [userCode],
      );

      return List.generate(maps.length, (i) => MenuModel.fromMap(maps[i]));
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query JOIN Menu: $e");
      return [];
    }
  }

  Future<List<MenuModel>> getMenuDeveloper() async {
    try {
      // Ambil hak akses CRUD langsung dari tabel menu_user (mu)
      final List<Map<String, dynamic>> maps = await _db.rawQuery('''
         SELECT id_menu,nama,id_header,level,urutan,url_menu FROM menu order by id_menu,id_header,urutan
        ''');

      return List.generate(maps.length, (i) => MenuModel.fromMap(maps[i]));
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query Menu Developer: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllMenu() async {
    try {
      String sql =
          "SELECT menu.*,m.nama as header FROM menu left join menu m on(m.id_menu = menu.id_header) order by id_menu,id_header,urutan";

      final List<Map<String, dynamic>> maps = await _db.rawQuery(sql);

      if (maps.isNotEmpty) {
        return maps;
      } else {
        return [];
      }
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query Menu: $e");
      return [];
    }
  }

  Future<List<MenuModel>> getHeaderMenu() async {
    try {
      // Ambil semua menu dari tabel menu tanpa filter user
      final List<Map<String, dynamic>> maps = await _db.rawQuery('''
        SELECT 
          m.id_menu, 
          m.nama, 
          m.id_header, 
          m.level, 
          m.urutan, 
          m.url_menu,
          1 AS `read`, 
          1 AS `create`, 
          1 AS `update`, 
          1 AS `delete`
        FROM menu m where (m.url_menu='' or m.url_menu = '#')
        ORDER BY m.urutan ASC
      ''');

      return List.generate(maps.length, (i) => MenuModel.fromMap(maps[i]));
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query Menu Developer: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> insertMenu(
    Map<String, dynamic> menu,
  ) async {
    try {
      final int idHeader = int.tryParse(menu['id_header'].toString()) ?? 0;
      final int level = int.tryParse(menu['level'].toString()) ?? 0;
      final int urutan = int.tryParse(menu['urutan'].toString()) ?? 0;
      String rawId = menu['id_menu']?.toString().trim() ?? '';

      // Jika string kosong atau bernilai "0", buat ID baru. Jika ada isinya, parse ke int.
      int idMenu = (rawId.isEmpty || rawId == '0')
          ? await generateMenuId()
          : (int.tryParse(rawId) ?? await generateMenuId());

      await _db.rawInsert(
        '''
      INSERT INTO menu (id_menu, nama, id_header, level, urutan, url_menu, `read`, `create`, `update`, `delete`)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          idMenu,
          menu['nama'] ?? '',
          idHeader,
          level,
          urutan,
          menu['url_menu'] ?? '#',
          menu['read'] ?? 0,
          menu['create'] ?? 0,
          menu['update'] ?? 0,
          menu['delete'] ?? 0,
        ],
      );

      // Ambil data terbaru setelah insert
      final List<Map<String, dynamic>> maps = await _db.query('menu');
      return maps;
    } catch (e) {
      print('❌ ERROR [insertMenu]: $e');
      SnackbarHelper.danger("Error SQLite Query Insert Menu: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> updateMenu(
    Map<String, dynamic> menu,
  ) async {
    try {
      final int idHeader = int.tryParse(menu['id_header'].toString()) ?? 0;
      final int level = int.tryParse(menu['level'].toString()) ?? 0;
      final int urutan = int.tryParse(menu['urutan'].toString()) ?? 0;
      final int idMenu = int.tryParse(menu['id_menu'].toString()) ?? 0;

      await _db.rawUpdate(
        '''
        UPDATE menu 
        SET nama = ?,
            id_header = ?,
            level = ?,
            urutan = ?,
            url_menu = ?,
            `read` = ?,
            `create` = ?,
            `update` = ?,
            `delete` = ?
        WHERE id_menu = ?
        ''',
        [
          menu['nama'] ?? '',
          idHeader,
          level,
          urutan,
          menu['url_menu'] ?? '#',
          menu['read'] ?? 0,
          menu['create'] ?? 0,
          menu['update'] ?? 0,
          menu['delete'] ?? 0,
          idMenu,
        ],
      );

      // Ambil data terbaru setelah update
      final List<Map<String, dynamic>> maps = await _db.query('menu');
      return maps;
    } catch (e) {
      print('❌ ERROR [updateMenu]: $e');
      Get.snackbar("Error", "Error SQLite Query Update Menu: $e");
      return [];
    }
  }

  /// Generates an ID with the format YYMMDD0001 (e.g., 2607300001)
  Future<int> generateMenuId() async {
    try {
      // 1. Ambil prefix tanggal hari ini (Format YYMMDD)
      String datePrefix = DateFormat('yyMMdd').format(DateTime.now());

      // 2. Cari ID tertinggi pada tanggal hari ini (antara YYMMDD0000 s/d YYMMDD9999)
      int minId = int.parse("${datePrefix}0000");
      int maxId = int.parse("${datePrefix}9999");

      final result = await _db.rawQuery(
        '''
        SELECT MAX(id_menu) as max_id FROM menu 
        WHERE id_menu >= ? AND id_menu <= ?
      ''',
        [minId, maxId],
      );

      int nextNumber = 1;

      // 3. Jika sudah ada data di hari ini, tambahkan +1
      if (result.isNotEmpty && result.first['max_id'] != null) {
        int lastId = result.first['max_id'] as int;
        // Ambil 4 digit terakhir
        int lastSequence = lastId % 10000;
        nextNumber = lastSequence + 1;
      }

      // 4. Format nomor urut menjadi 4 digit (misal: 1 -> 0001)
      String sequenceString = nextNumber.toString().padLeft(4, '0');

      // 5. Gabungkan prefix dan nomor urut menjadi ID integer
      int newId = int.parse("$datePrefix$sequenceString");

      print('🔍 DEBUG [Generated ID]: $newId');
      return newId;
    } catch (e) {
      print('❌ ERROR [generateMenuId]: $e');
      // Fallback jika error (pakai timestamp acak/default)
      String fallbackPrefix = DateFormat('yyMMdd').format(DateTime.now());
      return int.parse("${fallbackPrefix}0001");
    }
  }

  /// Menghapus menu berdasarkan id_menu
  Future<bool> deleteMenu(int idMenu) async {
    try {
      final int rows = await _db.rawDelete(
        'DELETE FROM menu WHERE id_menu = ?',
        [idMenu],
      );
      return rows > 0;
    } catch (e) {
      print('❌ ERROR [deleteMenu]: $e');
      Get.snackbar("Error", "Error SQLite Query Update Menu: $e");
      return false;
    }
  }
}
