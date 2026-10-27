import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✨ TAMBAHKAN BARIS INI:
export 'package:sqflite_common_ffi/sqflite_ffi.dart' show Database;
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class UserRepository {
  final Database _db;

  UserRepository(this._db);

  Future<List<Map<String, dynamic>>> getAllUserSystem() async {
    try {
      String sql = "select * from user order by code asc";

      final List<Map<String, dynamic>> maps = await _db.rawQuery(sql);

      if (maps.isNotEmpty) {
        return maps;
      } else {
        return [];
      }
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query User System: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> insertUserSystem(
    Map<String, dynamic> data,
  ) async {
    try {
      String sql =
          "insert into user (code, username, password, email, nama_panggilan, supervisor, phone, foto) values (@code, @username, @password, @email, @nama_user, @supervisor, @phone, @foto)";

      final List<Map<String, dynamic>> maps = await _db.rawQuery(sql, [
        data['code'],
        data['username'],
        data['password'],
        data['email'],
        data['nama_user'],
        data['is_supervisor'],
        data['phone'],
        data['foto'],
      ]);

      // 2. Ambil data terbaru dari DB untuk dikembalikan
      List<Map<String, dynamic>> insertUser = await _db.rawQuery(
        "SELECT * FROM user WHERE code = ?",
        [data['code']],
      );

      if (insertUser.isNotEmpty) {
        return insertUser;
      } else {
        return [];
      }
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query User System: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> updateUserSystem(
    Map<String, dynamic> data,
  ) async {
    try {
      final bool hasPassword =
          data['password'] != null && data['password'].toString().isNotEmpty;

      if (hasPassword) {
        String sql =
            "UPDATE user SET username=?, password=?, email=?, nama_panggilan=?, supervisor=?, phone=?, foto=? WHERE code=?";

        // 1. Jalankan rawUpdate
        await _db.rawUpdate(sql, [
          data['username'],
          data['password'],
          data['email'],
          data['nama_user'],
          data['is_supervisor'],
          data['phone'],
          data['foto'],
          data['code'],
        ]);
      } else {
        String sql =
            "UPDATE user SET username=?, email=?, nama_panggilan=?, supervisor=?, phone=?, foto=? WHERE code=?";

        await _db.rawUpdate(sql, [
          data['username'],
          data['email'],
          data['nama_user'],
          data['is_supervisor'],
          data['phone'],
          data['foto'],
          data['code'],
        ]);
      }

      // 2. Ambil data terbaru dari DB untuk dikembalikan
      List<Map<String, dynamic>> updatedUser = await _db.rawQuery(
        "SELECT * FROM user WHERE code = ?",
        [data['code']],
      );
      return updatedUser;
    } catch (e) {
      print("Error Update User: $e");
      SnackbarHelper.danger("Error SQLite Query User System: $e");
      return [];
    }
  }

  Future<bool> deleteUserSystem(String userCode) async {
    try {
      // delete hak akses user jika ada //
      final menuUserResult = await _db.rawDelete(
        'DELETE FROM menu_user WHERE user_code = ?',
        [userCode],
      );

      // delete user //
      final userResult = await _db.rawDelete(
        'DELETE FROM user WHERE code = ?',
        [userCode],
      );
      return userResult > 0;
    } catch (e) {
      SnackbarHelper.danger("Error menghapus data user: $e");
      return false;
    }
  }

  /// Generates an ID with the format YYMMDD0001 (e.g., 2607300001)
  Future<String> generateUserCode() async {
    try {
      // 1. Ambil prefix tanggal hari ini (Format YYMMDD)
      String datePrefix = DateFormat('yyMMdd').format(DateTime.now());

      // 2. Cari ID tertinggi pada tanggal hari ini (antara YYMMDD0000 s/d YYMMDD9999)
      String minId = "USR-${datePrefix}0000";
      String maxId = "USR-${datePrefix}9999";

      final result = await _db.rawQuery(
        '''
          SELECT MAX(code) as max_id FROM user
          WHERE code >= ? AND code <= ?
        ''',
        [minId, maxId],
      );

      int nextNumber = 1;

      // 3. Jika sudah ada data di hari ini, tambahkan +1
      if (result.isNotEmpty && result.first['max_id'] != null) {
        String lastId = result.first['max_id'] as String;
        // Ambil 4 digit terakhir
        int lastSequence = int.parse(lastId.substring(7));
        nextNumber = lastSequence + 1;
      }

      // 4. Format nomor urut menjadi 4 digit (misal: 1 -> 0001)
      String sequenceString = nextNumber.toString().padLeft(4, '0');

      // 5. Gabungkan prefix dan nomor urut menjadi ID integer
      String newId = "USR-$datePrefix$sequenceString";

      print('🔍 DEBUG [Generated ID]: $newId');
      return newId;
    } catch (e) {
      print('❌ ERROR [generateMenuId]: $e');
      // Fallback jika error (pakai timestamp acak/default)
      String fallbackPrefix = DateFormat('yyMMdd').format(DateTime.now());
      return "USR-${fallbackPrefix}0001";
    }
  }
}
