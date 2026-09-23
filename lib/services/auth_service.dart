import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://instaai-production.up.railway.app/auth',
    ),
  );

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await dio.post(
      '/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    final response = await dio.post(
      '/register',
      data: {
        "email": email,
        "password": password,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getProfile(
    String token,
  ) async {
    final response = await dio.get(
      '/profile',
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }
}