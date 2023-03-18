import 'dart:async';
import 'dart:io';
import 'database_image.dart';

class ImageStreamm {
  final databaseImage = DatabaseImage.instance;
  final _imageStreamController = StreamController<List<File>>.broadcast();
  Stream<List<File>> get imagesStream => _imageStreamController.stream;

  Future<void> updateImages() async {
    final images = await databaseImage.getImages();
    _imageStreamController.sink.add(images);
    print("addddddddddddddddddddddddk");
  }

  void dispose() {
    _imageStreamController.close();
  }
}
