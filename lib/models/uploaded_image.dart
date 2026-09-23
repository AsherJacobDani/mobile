class UploadedImage {

  final String filename;

  final String path;

  UploadedImage({

    required this.filename,

    required this.path,

  });

  factory UploadedImage.fromJson(
      Map<String, dynamic> json) {

    return UploadedImage(

      filename: json["filename"],

      path: json["path"],

    );

  }

}