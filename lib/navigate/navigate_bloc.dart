import 'package:bloc/bloc.dart';
import 'navigate_event.dart';
import 'navigate_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database_image.dart';

class NavigateBloc extends Bloc<NavigateEvent, NavigateState> {
  final DatabaseImage databaseImage = DatabaseImage.instance;

  final ImagePicker picker = ImagePicker();
  NavigateBloc(NavigateState initialState) : super(initialState) {
    on<CameraNavigateEvent>((event, emit) async {
      final pickerFile = await picker.getImage(source: ImageSource.camera);
      final imageFile = File(pickerFile!.path);

      await databaseImage.insertImage(imageFile);
      List<File> list = await databaseImage.getImages();
      print(list.length);
      emit(CameraState());
    });

    on<GarellyNavigateEvent>((event, emit) async {
      final pickerFile = await picker.getImage(source: ImageSource.gallery);
      final imageFile = File(pickerFile!.path);

      await databaseImage.insertImage(imageFile);
      List<File> list = await databaseImage.getImages();
      print(list.length);
      emit(GarellyState());
    });
  }
}
