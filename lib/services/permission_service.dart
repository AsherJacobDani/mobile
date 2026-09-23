import 'package:photo_manager/photo_manager.dart';

class PermissionService {

  static Future<bool> requestGalleryPermission() async {

    final result =
        await PhotoManager.requestPermissionExtend();

    return result.hasAccess;

  }

  static Future<void> openSettings() async {

    await PhotoManager.openSetting();

  }

}