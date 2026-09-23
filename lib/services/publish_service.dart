import 'package:dio/dio.dart';

class PublishService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://instaai-production.up.railway.app",
    ),
  );

  Future<Map<String, dynamic>> publishDraft(
    String token,
    int draftId,
  ) async {
    try {
      final response = await dio.post(
        "/publish/$draftId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data["detail"] ??
              "Failed to publish draft.",
        );
      }

      throw Exception(e.message);
    }
  }
}