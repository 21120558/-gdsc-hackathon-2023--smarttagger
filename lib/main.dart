import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'database_helper.dart';

import 'package:learningdart/navigate/navigate_bloc.dart';
import 'package:learningdart/navigate/navigate_event.dart';
import 'package:learningdart/navigate/navigate_state.dart';

import 'topic_stream.dart';

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  final dbHelper = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xF0F0F0)
          ),
          padding: EdgeInsets.only(left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Logo Text',
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold
                )),
                padding: EdgeInsets.only(top: 48, bottom: 20),
              ),
              TopicStream(dbHelper: dbHelper),
              _BarScreen(),
            ],
          ),
        ),
      ),
    );
  }
}



// class SearchForm extends StatefulWidget {
//   @override
//   _SearchFormState createState() => _SearchFormState();
// }

// class _SearchFormState extends State<SearchForm> {
//   late SearchBloc _searchBloc;

//   @override
//   void initState() {
//     super.initState();
//     _searchBloc = BlocProvider.of<SearchBloc>(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white
//           ),
//           child: TextField(
//             onChanged: (searchText) {
//               _searchBloc.add(SearchTextChanged(searchText: searchText));
//             },
//             decoration: InputDecoration(
//               border: InputBorder.none,
//               labelText: 'Search',
//               prefixIcon: Icon(Icons.search),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


Widget _BarScreen() {
    NavigateBloc navigateBloc = NavigateBloc(HomepageState());
    return BlocProvider<NavigateBloc>(
        create: (_) => navigateBloc,
        child: Container(
          child: Row(
            children: [
              _buildIconBar(Icons.camera_alt, () async {
                navigateBloc.add(CameraNavigateEvent());
              }),
              Spacer(),
              _buildIconBar(Icons.image, () {
                navigateBloc.add(GarellyNavigateEvent());
              }),
              _buildIconBar(Icons.image, () async {
                DatabaseHelper dbHelper = DatabaseHelper.instance;
                await dbHelper.deleteAll();
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