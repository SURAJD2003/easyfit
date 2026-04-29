class LogoutRequest {
  final String refreshToken;

  LogoutRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}
