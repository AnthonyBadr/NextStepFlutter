class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();
  static const String baseUrl = 'http://192.168.1.100:8080';

  // Base URL

  // API Routes

//LoginApi
  static const String loginRoute = '$baseUrl/user/login';

//Register Api  
  //Register Api Therapist 
  
  
  static const String registerRoute = '$baseUrl/users/register';
  static const String userRoute = '$baseUrl/user';
  static const String profileRoute = '$baseUrl/user/profile';

  // Common headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Helper method to get user by ID
  static String getUserById(String id) => '$baseUrl/user/$id';
}