class AdminLoginModel {
  final String token;
  final String adminId;
  final String name;
  final String? email;

  const AdminLoginModel({
    required this.token,
    required this.adminId,
    required this.name,
    this.email,
  });

  factory AdminLoginModel.fromJson(Map<String, dynamic> json) {
    return AdminLoginModel(
      token: json['token']?.toString() ?? '',
      adminId: json['adminId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }
}