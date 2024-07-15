class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 1000);
  static const Duration receiveTimeout = Duration(seconds: 1000);

  static const String baseUrl = "http://192.168.68.109:5500/api/";

  // ====================== Auth Routes ======================
  static const String login = "user/login";
  static const String dashboard = "admin/dashboaerd";
}
