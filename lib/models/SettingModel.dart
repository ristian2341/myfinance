class SettingModel {
  final int? idSetting;
  final String? instansi;
  final String namaAplikasi;
  final String? logo;
  final String? backgroundApp;
  final String? iconApp;
  final String? emailNotif;
  final String? passwordNotif;
  final String? namaInstansi;
  final String? alamatInstansi;
  final String? kabupaten;
  final String? profinsi;

  SettingModel({
    required this.namaAplikasi,
    this.instansi,
    this.logo,
    this.backgroundApp,
    this.iconApp,
    this.emailNotif,
    this.passwordNotif,
    this.idSetting,
    this.namaInstansi,
    this.alamatInstansi,
    this.kabupaten,
    this.profinsi,
  });

  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      idSetting: map['id_setting'] is int
          ? map['id_setting']
          : int.parse(map['id_setting']?.toString() ?? '0'),
      instansi:
          map['instansi'] ??
          'Rtie Development', // Diberi fallback string kosong jika null
      namaAplikasi: map['nama_aplikasi'] ?? "Finance & Accounting",
      logo: map['logo'] ?? "assets/images/finance_accounting.png",
      backgroundApp: map['background'] ?? "",
      iconApp: map['icon_app'] ?? 'assets/images/app_icon.ico',
      emailNotif: map['email_notif'] ?? '',
      passwordNotif: map['password_email'],
      namaInstansi: map['instansi'] ?? 'My Finance',
      alamatInstansi: map['alamat_instansi'] ?? '',
      kabupaten: map['kabupaten'] ?? '',
      profinsi: map['profinsi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_setting': idSetting,
      'instansi': namaInstansi,
      'nama_aplikasi': namaAplikasi,
      'logo': logo,
      'background': backgroundApp,
      'icon': iconApp,
      'email_notif': emailNotif,
      'password_email': passwordNotif,
      'alamat_instansi': alamatInstansi,
      'kabupaten': kabupaten,
      'profinsi': profinsi,
    };
  }
}
