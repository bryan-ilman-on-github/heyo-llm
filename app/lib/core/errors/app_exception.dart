class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code, super.originalError});
}

class ToolExecutionException extends AppException {
  final String toolName;

  ToolExecutionException(super.message, {required this.toolName, super.code});
}
