import 'package:sqflite_common_ffi/sqflite_ffi.dart';

export 'package:sqflite_common_ffi/sqflite_ffi.dart' show Database;
import 'package:myfinance/utils/snackbar_helper.dart';

class GroupMenuRepository {
  final Database _db;

  GroupMenuRepository(this._db);

  /// Mengambil semua data header group_menu beserta jumlah menu terkait
  Future<List<Map<String, dynamic>>> getAllGroupMenu() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.rawQuery('''
        SELECT 
          gm.id_group_menu AS code, 
          gm.nama AS group_menu,
          gm.keterangan AS keterangan,
          COUNT(gmd.id_detail) AS total_menu
        FROM group_menu gm
        LEFT JOIN group_menu_detail gmd ON gm.id_group_menu = gmd.id_group_menu
        GROUP BY gm.id_group_menu
        ORDER BY gm.id_group_menu ASC
      ''');
      return maps;
    } catch (e) {
      print(e);
      SnackbarHelper.danger("Error SQLite Query Group Menu: $e");
      return [];
    }
  }

  /// Mengambil semua menu dari tabel `menu` untuk ditampilkan pada Form Detail
  Future<List<Map<String, dynamic>>> getAllMenuForDetail() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.rawQuery('''
        SELECT 
          m.id_menu, 
          m.nama AS nama_menu, 
          m.id_header, 
          m.level, 
          m.urutan, 
          m.url_menu
        FROM menu m
        ORDER BY m.id_header ASC, m.urutan ASC, m.id_menu ASC
      ''');
      return maps;
    } catch (e) {
      print(e);
      SnackbarHelper.danger("Error SQLite Query Menu Detail: $e");
      return [];
    }
  }

  /// Mengambil detail yang tersimpan untuk id_group_menu tertentu
  Future<List<Map<String, dynamic>>> getGroupMenuDetails(int idGroupMenu) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.rawQuery('''
        SELECT 
          id_detail,
          id_group_menu,
          id_menu,
          `read`,
          `create`,
          `update`,
          `delete`
        FROM group_menu_detail
        WHERE id_group_menu = ?
      ''', [idGroupMenu]);
      return maps;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Simpan Header dan Detail sekaligus menggunakan Transaction
  Future<bool> saveGroupMenu({
    int? idGroupMenu,
    required String nama,
    String? keterangan,
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      await _db.transaction((txn) async {
        int groupId;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (idGroupMenu != null && idGroupMenu > 0) {
          // UPDATE HEADER
          groupId = idGroupMenu;
          await txn.rawUpdate('''
            UPDATE group_menu 
            SET nama = ?, keterangan = ?, updated_at = ?
            WHERE id_group_menu = ?
          ''', [nama, keterangan ?? '', now, groupId]);

          // Hapus detail lama agar digantikan detail baru
          await txn.rawDelete('''
            DELETE FROM group_menu_detail WHERE id_group_menu = ?
          ''', [groupId]);
        } else {
          // INSERT HEADER BARU
          groupId = await txn.rawInsert('''
            INSERT INTO group_menu (nama, keterangan, created_at, updated_at)
            VALUES (?, ?, ?, ?)
          ''', [nama, keterangan ?? '', now, now]);
        }

        // INSERT DETAILS YANG DIPILIH
        for (var d in details) {
          await txn.rawInsert('''
            INSERT INTO group_menu_detail (
              id_group_menu, id_menu, `read`, `create`, `update`, `delete`, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''', [
            groupId,
            d['id_menu'],
            d['read'] ?? 0,
            d['create'] ?? 0,
            d['update'] ?? 0,
            d['delete'] ?? 0,
            now,
            now,
          ]);
        }
      });
      return true;
    } catch (e) {
      print(e);
      SnackbarHelper.danger("Gagal menyimpan Group Menu: $e");
      return false;
    }
  }

  /// Hapus Group Menu beserta seluruh detailnya
  Future<bool> deleteGroupMenu(String code) async {
    try {
      final int id = int.tryParse(code) ?? 0;
      await _db.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM group_menu_detail WHERE id_group_menu = ?',
          [id],
        );
        await txn.rawDelete(
          'DELETE FROM group_menu WHERE id_group_menu = ?',
          [id],
        );
      });
      return true;
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query Delete Group Menu: $e");
      return false;
    }
  }
}
