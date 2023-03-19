// image_event.dart
import '../database/database_helper.dart';
import 'package:meta/meta.dart';
import 'dart:io';


@immutable
abstract class ImageEvent {}

class LoadImagesByTopicId extends ImageEvent {
  final int topicId;

  LoadImagesByTopicId({required this.topicId});
}

class LoadImagesForSelectedTopic extends ImageEvent {
  final int topicId;

  LoadImagesForSelectedTopic({required this.topicId});
}

class DisplayTopicImagesEvent extends ImageEvent {
  final List<File> images;

  DisplayTopicImagesEvent({required this.images});
}

class BackPressedEvent extends ImageEvent {}
