import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'database_image.dart';

import 'package:learningdart/navigate/navigate_bloc.dart';
import 'package:learningdart/navigate/navigate_event.dart';
import 'package:learningdart/navigate/navigate_state.dart';
import 'ImageStream.dart';

ImageStreamm imageStreamm = ImageStreamm();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  DatabaseImage databaseImage = DatabaseImage.instance;
  Widget _BarScreen() {
    NavigateBloc navigateBloc = NavigateBloc(HomepageState());
    return BlocProvider<NavigateBloc>(
        create: (_) => navigateBloc,
        child: Container(
          child: Row(
            children: [
              _buildIconBar(Icons.camera_alt, () async {
                final completer = Completer<void>();

                final navigateSubscription =
                    navigateBloc.stream.listen((state) async {
                  if (state is CameraState) {
                    await imageStreamm.updateImages().then((value) {
                      completer.complete();
                    });
                  }
                });

                navigateBloc.add(CameraNavigateEvent());
                completer.future.then((_) {
                  navigateSubscription.cancel();
                });
              }),
              Spacer(),
              _buildIconBar(Icons.image, () {
                final completer = Completer<void>();

                final navigateSubscription =
                    navigateBloc.stream.listen((state) {
                  if (state is GarellyState) {
                    imageStreamm.updateImages().then((_) {
                      completer.complete();
                    });
                  }
                });

                navigateBloc.add(GarellyNavigateEvent());
                completer.future.then((_) {
                  navigateSubscription.cancel();
                });
              }),
              Spacer(),
              _buildIconBar(Icons.chrome_reader_mode, () async {
                await databaseImage.deleteTable();
                await imageStreamm.updateImages();
              }),
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFAE7DD1),
            borderRadius: BorderRadius.circular(35),
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
        ));
  }

  Widget _buildIconBar(IconData iconData, Function action) {
    return Container(
      child: IconButton(
        icon: Icon(iconData),
        onPressed: () {
          action();
        },
        iconSize: 38.0,
        color: Color(0xFF2E004D),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: Color(0xFFF8F2FA)),
      width: 64,
      height: 64,
    );
  }

  @override
  Widget build(BuildContext context) {
    imageStreamm.updateImages();
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
              child: Container(
                child: Flex(
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          "Hi user",
                          style: TextStyle(
                            fontSize: 42,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      flex: 6,
                    ),
                    Flexible(
                      child: _BarScreen(),
                      flex: 5,
                    )
                  ],
                  direction: Axis.vertical,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F2FA),
                ),
                padding: EdgeInsets.fromLTRB(38, 0, 38, 0),
              ),
              flex: 4),
          Flexible(
              child: Container(
                child: Column(
                  children: [
                    Container(
                        child: Text(
                          'Recently',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 22,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 6)),
                    Column(
                      children: [
                        _buildRecentlySection('Today'),
                        _buildRecentlySection('Yesterday'),
                        _buildRecentlySection('Tomorrow'),
                      ],
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF3DAFF),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                padding: EdgeInsets.fromLTRB(38, 8, 38, 8),
              ),
              flex: 6),
        ],
      )),
    );
  }
}

Widget _buildRecentlySection(String timestamp) {
  return Container(
    child: Column(
      children: [
        Container(
          child: Text(
            timestamp,
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 28,
            ),
          ),
          margin: EdgeInsets.only(bottom: 12),
          alignment: Alignment.centerLeft,
        ),
        StreamBuilder(
            stream: imageStreamm.imagesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final images = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (images.length - 1 >= 0)
                        ? Container(
                            child: Image(
                              image: FileImage(images[images.length - 1]),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                          ),
                    (images.length - 2 >= 0)
                        ? Container(
                            child: Image(
                              image: FileImage(images[images.length - 2]),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                          ),
                    (images.length - 3 >= 0)
                        ? Container(
                            child: Image(
                              image: FileImage(images[images.length - 3]),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                          ),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
      ],
    ),
    margin: EdgeInsets.only(top: 24),
  );
}
