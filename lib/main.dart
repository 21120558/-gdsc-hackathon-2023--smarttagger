import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'database/database_helper.dart';

import 'package:learningdart/navigate/navigate_bloc.dart';
import 'package:learningdart/navigate/navigate_event.dart';
import 'package:learningdart/navigate/navigate_state.dart';

import 'stream_image/topic_stream.dart';

void main() async {
  runApp(MaterialApp(home: SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0F0F0),
        ),
        child: Center(
          child: SvgPicture.asset(
            'images/splash.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final dbHelper = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xF0F0F0)),
        padding: EdgeInsets.only(left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: SvgPicture.asset(
                width: 28,
                height: 28,
                'images/logo.svg',
              ),
              padding: EdgeInsets.only(top: 64, bottom: 20),
              alignment: Alignment.center,
            ),
            TopicStream(dbHelper: dbHelper),
            _BarScreen(),
          ],
        ),
      ),
    );
  }
}

Widget _BarScreen() {
  NavigateBloc navigateBloc = NavigateBloc(HomepageState());
  return BlocProvider<NavigateBloc>(
      create: (_) => navigateBloc,
      child: Row(
        children: [
          Spacer(),
          Container(
            child: Row(
              children: [
                Container(
                  child: _buildIconBar(Icons.camera_alt, () async {
                    navigateBloc.add(CameraNavigateEvent());
                  }),
                  decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.white))),
                ),
                Container(
                  child: _buildIconBar(Icons.image, () {
                    navigateBloc.add(GarellyNavigateEvent());
                  }),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 175, 43, 33),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
            margin: EdgeInsets.fromLTRB(8, 16, 0, 16),
          ),
        ],
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
      color: Colors.white,
    ),
    width: 56,
    height: 56,
    margin: EdgeInsets.only(left: 6, right: 6),
  );
}
