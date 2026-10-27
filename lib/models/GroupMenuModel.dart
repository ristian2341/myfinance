import 'package:get/get.dart';

class GroupMenuModel {
  final String code;
  final String groupMenu;
  final String keterangan;
  final int idMenu;
  final String namaMenu;
  final bool isHeader; // Indikator apakah item ini Parent/Header Group

  final RxBool isSelected; // Checkbox centang menu yang dipilih
  final RxBool canCreate; // C
  final RxBool canRead; // R
  final RxBool canUpdate; // U
  final RxBool canDelete; // D
  final RxBool canAll; // A

  GroupMenuModel({
    required this.code,
    required this.groupMenu,
    this.keterangan = '',
    required this.idMenu,
    required this.namaMenu,
    this.isHeader = false,
    bool isSelected = false,
    bool canCreate = false,
    bool canRead = false,
    bool canUpdate = false,
    bool canDelete = false,
    bool canAll = false,
  })  : isSelected = isSelected.obs,
        canCreate = canCreate.obs,
        canRead = canRead.obs,
        canUpdate = canUpdate.obs,
        canDelete = canDelete.obs,
        canAll = canAll.obs;

  factory GroupMenuModel.fromMap(Map<String, dynamic> map) {
    bool parseBool(dynamic val) =>
        val == true ||
        val == 1 ||
        val == '1' ||
        val.toString().toLowerCase() == 'true';

    final bool read = parseBool(map['read']) || parseBool(map['can_read']);
    final bool create = parseBool(map['create']) || parseBool(map['can_create']);
    final bool update = parseBool(map['update']) || parseBool(map['can_update']);
    final bool delete = parseBool(map['delete']) || parseBool(map['can_delete']);
    final bool selected =
        parseBool(map['is_selected']) || read || create || update || delete;

    return GroupMenuModel(
      code: map['code']?.toString() ??
          map['id_group_menu']?.toString() ??
          map['id_menu']?.toString() ??
          '',
      groupMenu: map['group_menu']?.toString() ??
          map['nama_group']?.toString() ??
          map['nama']?.toString() ??
          '',
      keterangan: map['keterangan']?.toString() ?? '',
      idMenu: map['id_menu'] is int
          ? map['id_menu']
          : int.tryParse(map['id_menu']?.toString() ?? '0') ?? 0,
      namaMenu: map['nama_menu']?.toString() ?? map['nama']?.toString() ?? '',
      isHeader: parseBool(map['is_header']) ||
          (map['id_header'] == 0 ||
              map['url_menu'] == '#' ||
              map['url_menu'] == ''),
      isSelected: selected,
      canCreate: create,
      canRead: read,
      canUpdate: update,
      canDelete: delete,
      canAll: parseBool(map['can_all']) ||
          (read && create && update && delete),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'group_menu': groupMenu,
      'keterangan': keterangan,
      'id_menu': idMenu,
      'nama_menu': namaMenu,
      'is_header': isHeader,
      'is_selected': isSelected.value ? 1 : 0,
      'can_create': canCreate.value ? 1 : 0,
      'can_read': canRead.value ? 1 : 0,
      'can_update': canUpdate.value ? 1 : 0,
      'can_delete': canDelete.value ? 1 : 0,
      'can_all': canAll.value ? 1 : 0,
    };
  }
}
