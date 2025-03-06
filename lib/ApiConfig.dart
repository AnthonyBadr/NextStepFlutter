class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Base URL
  static const String baseUrl = 'http://192.168.1.105:8080';

  // API Routes
  static const String loginRoute = '$baseUrl/user/login';
  static const String registerRoute = '$baseUrl/user/register';
  static const String userRoute = '$baseUrl/user';
  static const String profileRoute = '$baseUrl/user/profile';

  // Common headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Helper method to get user by ID
  static String getUserById(String id) => '$baseUrl/user/$id';
}