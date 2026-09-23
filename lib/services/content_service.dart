import 'package:dio/dio.dart';

import '../models/draft.dart';

class ContentService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://instaai-production.up.railway.app",
    ),
  );

  Future<Draft> generateCaption(
    String username,
    List<String> imagePaths,
  ) async {
    final response = await dio.post(
      "/content/generate",
      data: {
        "username": username,
        "image_paths": imagePaths,
      },
    );

    print("CONTENT RESPONSE");
    print(response.data);
    print(response.data.runtimeType);

    return Draft.fromJson(
      response.data,
    );
  }
}