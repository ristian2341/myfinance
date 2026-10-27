import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

export 'package:sqflite_common_ffi/sqflite_ffi.dart' show Database;
import 'package:myfinance/models/SettingModel.dart';
import 'package:myfinance/utils/snackbar_helper.dart';

class SettingRepository {
  final Database _db;
  SettingRepository(this._db);

  Future<SettingModel?> getSettingApp() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'setting',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return SettingModel.fromMap(maps.first);
      }

      return null;
    } catch (e) {
      SnackbarHelper.danger("Error SQLite Query Setting: $e");
      return null;
    }
  }

  // ✨ FUNGSI BARU: Otomatis Update jika data ada, atau Insert jika data kosong
  Future<void> saveOrUpdateSettingApp(SettingModel setting) async {
    try {
      // 1. Cek apakah di database sudah ada baris data dengan id_setting tersebut
      final List<Map<String, dynamic>> maps = await _db.query(
        'setting',
        where: 'id_setting = ?',
        whereArgs: [setting.idSetting],
      );

      if (maps.isNotEmpty) {
        // A. JIKA ADA: Jalankan perintah UPDATE
        await _db.update(
          'setting',
          setting.toMap(),
          where: 'id_setting = ?',
          whereArgs: [setting.idSetting],
        );
        SnackbarHelper.success('Setting berhasil diperbarui', title: 'Sukses');
      } else {
        // B. JIKA TIDAK ADA: Jalankan perintah INSERT (Input Data Baru)
        await _db.insert('setting', setting.toMap());
        SnackbarHelper.success(
          'Setting baru berhasil disimpan',
          title: 'Sukses',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      SnackbarHelper.danger("Error SQLite Save/Update Setting: $e");
    }
  }
}
