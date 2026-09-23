class GalleryMedia {

  final String id;

  final String path;

  final String fileName;

  final int width;

  final int height;

  final int fileSize;

  final DateTime created;

  final bool isVideo;

  GalleryMedia({

    required this.id,

    required this.path,

    required this.fileName,

    required this.width,

    required this.height,

    required this.fileSize,

    required this.created,

    required this.isVideo,

  });

}