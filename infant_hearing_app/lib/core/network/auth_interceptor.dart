class AuthInterceptor {
  static Map<String, String> getHeaders({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}