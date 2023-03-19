// image_state.dart

import 'package:meta/meta.dart';
import '../database/database_helper.dart';

@immutable
abstract class ImageState {}

class ImageInitial extends ImageState {}

class OnBackPressed extends ImageState {}

class ImagesLoaded extends ImageState {
  final List<ImageModel> images;

  ImagesLoaded({required this.images});
}
