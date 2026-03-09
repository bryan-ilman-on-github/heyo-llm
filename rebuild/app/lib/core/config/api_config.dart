class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'HEYO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String prepareEndpoint = '$baseUrl/api/chat/prepare';
  static const String respondEndpoint = '$baseUrl/api/chat/respond';
  static const String attachmentInspectEndpoint =
      '$baseUrl/api/attachments/inspect';
  static const String entitySummaryEndpoint = '$baseUrl/api/entities/summarize';
  static const String quotaEndpoint = '$baseUrl/api/quota';
  static const String healthEndpoint = '$baseUrl/health';
}
