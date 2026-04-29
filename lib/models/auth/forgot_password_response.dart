class ForgotPasswordResponse {
  final String? message;

  ForgotPasswordResponse({
    this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'],
    );
  }
}
