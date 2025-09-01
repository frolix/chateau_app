import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../models/place_photo.dart';
import '../repositories/photos_repository.dart';
import 'package:chatau/core/di/di.dart';

class PlacePhotosService {
  final _picker = ImagePicker();
  final _repo = sl<PhotosRepository>();

  Future<void> captureForPlace(String placeId) async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (x == null) return;

    // 1) Копія у папку додатка (щоб відображати в твоєму UI)
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'Photos'));
    await photosDir.create(recursive: true);

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final fileName = '${placeId}_$id.jpg';
    final savedPath = p.join(photosDir.path, fileName);
    await File(x.path).copy(savedPath);

    // 2) Зберегти у системну Галерею
    final bytes = await File(savedPath).readAsBytes();
    await ImageGallerySaver.saveImage(
      Uint8List.fromList(bytes),
      quality: 100,
      name: "Chatau_$id",
    );

    // 3) Запис у репозиторій
    await _repo.add(
      PlacePhoto(
        id: id,
        placeId: placeId,
        path: savedPath, // локальний шлях додатка
        createdAt: DateTime.now(),
      ),
    );
  }
}
