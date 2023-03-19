import 'package:bloc/bloc.dart';
import 'navigate_event.dart';
import 'navigate_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database_helper.dart';

const String API_ENDPOINT = "FASTAPI_DEPLOY_AI";

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class NavigateBloc extends Bloc<NavigateEvent, NavigateState> {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  final ImagePicker picker = ImagePicker();
  NavigateBloc(NavigateState initialState) : super(initialState) {
    on<CameraNavigateEvent>((event, emit) async {
      final pickerFile = await picker.getImage(source: ImageSource.camera);
      final imageFile = File(pickerFile!.path);

      String topicName = await sendImageToAPIAndGetTopic(imageFile);
      await databaseHelper.insertTopicWithImageByName(
          topicName.capitalize(), imageFile);

      List<Topic> list = await databaseHelper.getAllTopics();
      print(list.length);
      emit(CameraState());
    });

    on<GarellyNavigateEvent>((event, emit) async {
      final pickerFile = await picker.getImage(source: ImageSource.gallery);
      final imageFile = File(pickerFile!.path);

      String topicName = await sendImageToAPIAndGetTopic(imageFile);
      await databaseHelper.insertTopicWithImageByName(
          topicName.capitalize(), imageFile);

      List<Topic> list = await databaseHelper.getAllTopics();
      print(list.length);
      emit(GarellyState());
    });
  }

  Future<String> sendImageToAPIAndGetTopic(File imageFile) async {
    Uri uri = Uri.parse(API_ENDPOINT);
    http.MultipartRequest request = http.MultipartRequest('POST', uri);

    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(result);

      List<dynamic> resultList = jsonResponse["result"];

      List<String> resultStrings = resultList.map((e) => e.toString()).toList();

      return resultStrings[0];
    } else {
      return "unknown_topic";
    }
  }
}
