class ApiResponse {
  bool? status;
  String message;

  ApiResponse({
    this.status,
    required this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}
