class ApiError {
  final int? statusCode;
  final String message;

  const ApiError({
    this.statusCode,
    required this.message,
  });

  factory ApiError.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return ApiError(
      statusCode: statusCode ?? json['status_code'] as int?,
      message: json['message'] as String? ??
          json['error'] as String? ??
          'Something went wrong',
    );
  }

  @override
  String toString() =>
      'ApiError(statusCode: $statusCode, message: $message)';
}

class ApiResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  const ApiResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory ApiResult.success(T data) => ApiResult._(
        data: data,
        isSuccess: true,
      );

  factory ApiResult.failure(ApiError error) => ApiResult._(
        error: error,
        isSuccess: false,
      );

  bool get isFailure => !isSuccess;
}