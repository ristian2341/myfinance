class MenuModel {
  final int idMenu;
  final String nama;
  final int? idHeader;
  final int? level;
  final int? urutan;
  final String? urlMenu;
  final String? header;
  final bool canRead;
  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;

  MenuModel({
    required this.idMenu,
    required this.nama,
    this.idHeader,
    this.level,
    this.urutan,
    this.urlMenu,
    this.header,
    required this.canRead,
    required this.canCreate,
    required this.canUpdate,
    required this.canDelete,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      idMenu: map['id_menu'] is int
          ? map['id_menu']
          : int.parse(map['id_menu'].toString()),
      nama: map['nama'] ?? '',
      idHeader: map['id_header'],
      header: map['header'],
      level: map['level'],
      urutan: map['urutan'],
      urlMenu: map['url_menu'],
      canRead: (map['read'] ?? 0) == 1,
      canCreate: (map['create'] ?? 0) == 1,
      canUpdate: (map['update'] ?? 0) == 1,
      canDelete: (map['delete'] ?? 0) == 1,
    );
  }
}
