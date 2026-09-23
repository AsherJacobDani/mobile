import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://instaai-production.up.railway.app',
    ),
  );

  Future<String> getHealth() async {
    final response = await dio.get('/health');
    return response.data['message'];
  }
}