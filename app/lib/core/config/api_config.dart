class ApiConfig {
  // Change this to your server URL
  static const String baseUrl = 'https://geek-msie-sunrise-crystal.trycloudflare.com';

  // For local development
  // static const String baseUrl = 'http://localhost:8080';

  static const String chatEndpoint = '$baseUrl/api/chat';
  static const String toolsEndpoint = '$baseUrl/api/tools';
  static const String healthEndpoint = '$baseUrl/health';

  static const Duration timeout = Duration(seconds: 120);
  static const String defaultModel = 'llama3.1';
}
