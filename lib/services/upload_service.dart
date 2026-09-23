import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../models/uploaded_image.dart';

class UploadService {

  final Dio dio = Dio(

    BaseOptions(

      baseUrl: "https://instaai-production.up.railway.app",

    ),

  );

  Future<List<UploadedImage>> uploadImages(

      List<String> imagePaths,

      ) async {

    FormData formData = FormData();

    for (String path in imagePaths) {

      formData.files.add(

        MapEntry(

          "files",

          await MultipartFile.fromFile(

            path,

            filename: path.split("/").last,

            contentType: MediaType(

              "image",

              "jpeg",

            ),

          ),

        ),

      );

    }

    final response = await dio.post(

      "/upload/images",

      data: formData,

    );

    return (response.data as List)

        .map(

          (e) => UploadedImage.fromJson(e),

    )

        .toList();

  }

}