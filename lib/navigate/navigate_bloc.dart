import 'package:bloc/bloc.dart';
import 'navigate_event.dart';
import 'navigate_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database_helper.dart';

class NavigateBloc extends Bloc<NavigateEvent, NavigateState> {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  final ImagePicker picker = ImagePicker();
  NavigateBloc(NavigateState initialState) : super(initialState) {
    on<CameraNavigateEvent>((event, emit) async {
      final pickerFile = await picker.getImage(source: ImageSource.camera);
      final imageFile = File(pickerFile!.path);

      String topicName = await sendImageToAPIAndGetTopic(imageFile);
      await databaseHelper.insertTopicWithImageByName(topicName, imageFile);

      List<Topic> list = await databaseHelper.getAllTopics();
      print(list.length);
      emit(CameraState());
    });

    on<GarellyNavigateEvent>((event, emit) async {
      final pickerFile = await picker.getImage(source: ImageSource.gallery);
      final imageFile = File(pickerFile!.path);

      String topicName = await sendImageToAPIAndGetTopic(imageFile);
      await databaseHelper.insertTopicWithImageByName(topicName, imageFile);

      List<Topic> list = await databaseHelper.getAllTopics();
      print(list.length);
      emit(GarellyState());
    });
  }

  Future<String> sendImageToAPIAndGetTopic(File imageFile) async {
    // String apiUrl = "your_api_url_here";
    // Uri uri = Uri.parse(apiUrl);

    // // Tạo multipart request
    // http.MultipartRequest request = http.MultipartRequest('POST', uri);

    // // Đính kèm ảnh vào request
    // request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    // // Gửi request
    // http.StreamedResponse response = await request.send();

    // // Kiểm tra kết quả trả về
    // if (response.statusCode == 200) {
    //   // Lấy kết quả trả về dạng JSON
    //   String result = await response.stream.bytesToString();
    //   Map<String, dynamic> jsonResponse = jsonDecode(result);

    //   // Lấy tên topic từ kết quả trả về
    //   String topicName = jsonResponse['topic_name'];

      // Trả về tên topic
      return "Hiiiiiii";
    // } else {
    //   // Nếu có lỗi, trả về một giá trị mặc định
    //   return "unknown_topic";
    // }
  }
}
