import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✨ TAMBAHKAN BARIS INI:
export 'package:sqflite_common_ffi/sqflite_ffi.dart' show Database;
import 'package:myfinance/utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class UserAksesRepository {
  final Database _db;

  UserAksesRepository(this._db);
}