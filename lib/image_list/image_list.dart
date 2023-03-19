import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import 'image_bloc.dart';
import 'image_event.dart';
import 'image_state.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String imagePath;

  ImageViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            width: double.infinity,
            height: double.infinity,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class ImageListWidget extends StatefulWidget {
  final int topicId;
  final VoidCallback onBackPressed;
  final DatabaseHelper dbHelper;

  ImageListWidget(
      {required this.topicId,
      required this.onBackPressed,
      required this.dbHelper});

  @override
  _ImageListWidgetState createState() => _ImageListWidgetState();
}

class _ImageListWidgetState extends State<ImageListWidget> {
  late ImageBloc _imageBloc;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _imageBloc = BlocProvider.of<ImageBloc>(context);
    _imageBloc.add(LoadImagesByTopicId(topicId: widget.topicId));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPressed();

        return false;
      },
      child: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImagesLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: widget.dbHelper.getTopicTitleById(widget.topicId),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return Container(
                      padding: EdgeInsets.only(bottom: 12, top: 12),
                      child: Text(snapshot.data ?? '',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(0, 0, 0, 0.7),
                          )),
                    );
                  },
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                    itemCount: state.images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ImageViewer(imagePath: state.images[index].path)),
                              );
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(state.images[index].path),
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    // child: ListView.builder(
                    //   itemCount: state.images.length,
                    //   itemBuilder: (context, index) {
                    //     return ListTile(
                    //       leading: ,
                    //       title: Text('Image ${index + 1}'),
                    //     );
                    //   },
                  ),
                ),
              ],
            );
          } else if (state is ImageInitial) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text('Error: Unknown state'));
          }
        },
      ),
    );
  }
}
