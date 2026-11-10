import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✨ TAMBAHKAN BARIS INI:
export 'package:sqflite_common_ffi/sqflite_ffi.dart' show Database;

class UserAksesRepository {
  final Database _db;

  UserAksesRepository(this._db);
  Future<List<Map<String, dynamic>>> getUserAkses(String userCode) async {
    return await _db.rawQuery('SELECT * FROM user_akses WHERE code_user = ?', [
      userCode,
    ]);
  }
}
