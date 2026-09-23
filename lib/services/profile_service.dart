import 'package:dio/dio.dart';

import 'storage_service.dart';

class ProfileService {

  Future<Map<String, dynamic>>
  getProfile() async {

    final token =
    await StorageService
        .getToken();

    final response = await Dio().get(
      'https://instaai-production.up.railway.app/auth/profile',

      options: Options(
        headers: {
          "Authorization":
          "Bearer $token"
        },
      ),
    );

    return response.data;
  }
}