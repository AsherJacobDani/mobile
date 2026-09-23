import 'package:dio/dio.dart';

import '../models/recommendation.dart';
import '../models/uploaded_image.dart';

class RecommendationService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://instaai-production.up.railway.app",
    ),
  );

  Future<List<Recommendation>> recommendImages(
    String token,
    List<UploadedImage> images,
  ) async {

    print("RecommendationService Started");
    print(images.length);

    final body = {
      "images": images
          .map(
            (e) => {
              "filename": e.filename,
              "path": e.path,
            },
          )
          .toList(),
    };

    try {

      final response = await dio.post(

        "/ai/recommend",

        data: body,

        options: Options(

          headers: {

            "Authorization": "Bearer $token",

          },

        ),

      );

      return (response.data as List)

          .map(

            (e) => Recommendation.fromJson(e),

          )

          .toList();

    } catch (e, stack) {

      print("================================");
      print(e);
      print(stack);
      print("================================");

      rethrow;

    }

  }
}