class LogoutResponse {
  final String? message;

  LogoutResponse({
    this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      message: json['message'],
    );
  }
}
