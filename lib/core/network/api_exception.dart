/// Real backend error, parsed from the server.js envelope:
/// `{success:false, error:{code, message, request_id?}}`.
class ApiException implements Exception {
  final String code;
  final String message;
  final int status;
  final String? requestId;

  const ApiException({
    required this.code,
    required this.message,
    required this.status,
    this.requestId,
  });

  @override
  String toString() => '$code: $message';
}
