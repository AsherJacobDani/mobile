import 'package:image_picker/image_picker.dart';

class LimitedGalleryService {

  final ImagePicker _picker = ImagePicker();

  Future<List<String>> pickImages() async {

    final List<XFile> images =
        await _picker.pickMultiImage();

    return images
        .map((e) => e.path)
        .toList();

  }

}