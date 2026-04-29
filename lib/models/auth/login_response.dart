class LoginResponse {
  final String? userId;
  final String? token;
  final String? refreshToken;
  final String? role;

  LoginResponse({
    this.userId,
    this.token,
    this.refreshToken,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      role: json['role'],
    );
  }
}
