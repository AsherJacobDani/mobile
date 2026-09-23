import 'package:dio/dio.dart';

import '../models/instagram_profile.dart';
import '../models/instagram_status.dart';

class InstagramService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://instaai-production.up.railway.app",
    ),
  );

  /// Get Instagram connection status
  Future<InstagramStatus> getStatus(
    String token,
  ) async {
    final response = await dio.get(
      "/instagram/status",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return InstagramStatus.fromJson(
      response.data,
    );
  }

  /// Get Instagram profile
  Future<InstagramProfile> getProfile(
    String token,
  ) async {
    final response = await dio.get(
      "/instagram/profile",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return InstagramProfile.fromJson(
      response.data,
    );
  }

  /// Get Facebook Login URL
  Future<String> getLoginUrl(
    String token,
  ) async {
    final response = await dio.get(
      "/instagram/login",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data["login_url"];
  }

  /// Disconnect Instagram account
  Future<void> disconnect(
    String token,
  ) async {
    await dio.post(
      "/instagram/disconnect",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
    /// Sync Instagram posts
  Future<Map<String, dynamic>> syncPosts(
    String token,
  ) async {
    final response = await dio.post(
      "/instagram/posts/sync",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  /// Analyze synced Instagram posts
  Future<Map<String, dynamic>> analyzePosts(
    String token,
  ) async {
    final response = await dio.post(
      "/instagram/posts/analyze",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  /// Generate Instagram preferences
  Future<Map<String, dynamic>> generatePreferences(
    String token,
  ) async {
    final response = await dio.post(
      "/instagram/preferences/generate",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  /// Get generated Instagram preferences
  Future<Map<String, dynamic>> getPreferences(
    String token,
  ) async {
    final response = await dio.get(
      "/instagram/preferences",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  /// Complete personalization workflow
  Future<void> preparePersonalization(
    String token,
  ) async {
    await syncPosts(token);

    await analyzePosts(token);

    await generatePreferences(token);
  }
}