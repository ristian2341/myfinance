class UserModel {
  final String? userCode;
  final String? username;
  final String? password;
  final String? namaUser;
  final int? isSupervisor;
  final String? foto;
  final String? phone;
  final String? verifyCode;
  final String? email;
  final String? accessToken;

  UserModel({
    required this.userCode,
    this.username,
    this.namaUser,
    this.password,
    this.foto,
    this.isSupervisor,
    this.phone,
    this.verifyCode,
    this.email,
    this.accessToken,
   
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userCode: map['code'] ?? '',
      username: map['username'] ?? '',
      namaUser: map['nama_panggilan'] ?? '',
      password: map['password'] ?? '',
      foto: map['foto'] ?? '',
      isSupervisor: map['supervisor'] ?? 0,
      phone: map['phone'] ?? '',
      verifyCode: map['verify_code'] ?? '',
      email: map['email'] ?? '',
      accessToken: map['access_token'] ?? '',
    );
  }
}
