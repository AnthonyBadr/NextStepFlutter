class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();
  static const String baseUrl = 'http://192.168.1.103:8080';

  // Base URL

  // API Routes

//LoginApi
  static const String loginRoute = '$baseUrl/user/login';

//Register Api  
  //Register Api Therapist 
  
  
  static const String registerRoute = '$baseUrl/CreateUser/users/register';
  static const String GetAllUsers= '$baseUrl/GetAllUsers/users';
  static const String UpdateUserById= '$baseUrl/UpdateUserById/users';
  static const String Login= '$baseUrl/Login/users';
  static const String userRoute = '$baseUrl/user';
  static const String profileRoute = '$baseUrl/user/profile';
  static const String uploadFile = '$baseUrl/upload';
  // Common headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Helper method to get user by ID
  static String getUserById(String id) => '$baseUrl/user/$id';
}