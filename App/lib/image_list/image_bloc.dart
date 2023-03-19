import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../database/database_helper.dart';

import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final DatabaseHelper dbHelper;
  late StreamSubscription _subscription;

  ImageBloc({required this.dbHelper}) : super(ImageInitial()) {
    on<LoadImagesByTopicId>(_loadImagesByTopicId);
    on<LoadImagesForSelectedTopic>(_loadImagesForSelectedTopic);
    on<BackPressedEvent>((event, emit) => emit(OnBackPressed()));
  }

  Future<void> _loadImagesByTopicId(
      LoadImagesByTopicId event, Emitter<ImageState> emit) async {
    try {
      final images = await dbHelper.getImagesByTopicId(event.topicId);
      if (images.isNotEmpty) {
        emit(ImagesLoaded(images: images));
      } else {
        emit(ImageInitial());
      }
    } catch (e) {
      //
    }
  }

  Future<void> _loadImagesForSelectedTopic(
      LoadImagesForSelectedTopic event, Emitter<ImageState> emit) async {
    try {
      final images = await dbHelper.getImagesByTopicId(event.topicId);
      if (images.isNotEmpty) {
        emit(ImagesLoaded(images: images));
      } else {
        emit(ImageInitial());
      }
    } catch (e) {
      //
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
