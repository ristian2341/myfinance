import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/models/GroupMenuModel.dart';

void main() {
  test('GroupMenuModel fromMap parsing test', () {
    final map = {
      'code': 'GM001',
      'group_menu': 'Admin',
      'keterangan': 'Administrator Group',
      'id_menu': 1,
      'nama_menu': 'Dashboard',
      'is_header': 0,
      'read': 1,
      'create': 1,
      'update': 0,
      'delete': 0,
    };

    final model = GroupMenuModel.fromMap(map);

    expect(model.code, 'GM001');
    expect(model.groupMenu, 'Admin');
    expect(model.idMenu, 1);
    expect(model.namaMenu, 'Dashboard');
    expect(model.canRead.value, isTrue);
    expect(model.canCreate.value, isTrue);
    expect(model.canUpdate.value, isFalse);
    expect(model.canDelete.value, isFalse);
  });
}

