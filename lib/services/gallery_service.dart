import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

import '../models/gallery_media.dart';

class GalleryService {

  Future<List<AssetPathEntity>> loadAlbums() async {

    return await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );

  }

  Future<List<AssetEntity>> scanGallery(
    int limit,
  ) async {

    final albums = await loadAlbums();

    if (albums.isEmpty) {

      return [];

    }

    final album = albums.first;

    final totalAssets = await album.assetCountAsync;

    return await album.getAssetListPaged(

      page: 0,

      size: limit == -1
          ? totalAssets
          : limit,

    );

  }

  Future<List<GalleryMedia>> loadMedia(
    int limit,
  ) async {

    final assets = await scanGallery(limit);

    List<GalleryMedia> media = [];

    for (final asset in assets) {

      final file = await asset.file;

      if (file == null) {

        continue;

      }

      media.add(

        GalleryMedia(

          id: asset.id,

          path: file.path,

          fileName: file.path.split('/').last,

          width: asset.width,

          height: asset.height,

          fileSize: await file.length(),

          created: asset.createDateTime,

          isVideo: asset.type == AssetType.video,

        ),

      );

    }

    return media;

  }

}