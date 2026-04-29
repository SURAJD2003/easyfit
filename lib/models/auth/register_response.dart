class RegisterResponse {
  final String? userId;
  final String? token;
  final String? refreshToken;
  final String? message;

  RegisterResponse({
    this.userId,
    this.token,
    this.refreshToken,
    this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId:       json['userId'],
      token:        json['token'],
      refreshToken: json['refreshToken'],
      message:      json['message'],
    );
  }
}