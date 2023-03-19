import 'package:flutter/material.dart';
import '../database/database_helper.dart';

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../image_list/image_bloc.dart';
import '../image_list/image_event.dart';
import '../image_list/image_state.dart';
import '../image_list/image_list.dart';

class TopicStream extends StatefulWidget {
  final DatabaseHelper dbHelper;

  TopicStream({required this.dbHelper});

  @override
  _TopicStreamState createState() => _TopicStreamState();
}

class _TopicStreamState extends State<TopicStream> {
  int? _selectedTopicId;

  void _onBackPressed() async {
    setState(() {
      _selectedTopicId = null;
    });
  }

  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return _selectedTopicId == null
        ? _buildTopicList(context)
        : _buildImageList(context);
  }

  Widget _buildTopicList(BuildContext context) {
    _initializeDatabase();
    return StreamBuilder<List<Topic>>(
      stream: widget.dbHelper.topicStream(),
      builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final topics = snapshot.data!;
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 12, top: 12),
                child: Text(
                  "Topic",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                  )
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 36),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        return TopicCard(
                          topic: topics[index],
                          dbHelper: widget.dbHelper,
                          onCardTap: (int topicId) {
                            setState(() {
                              _selectedTopicId = topicId;
                            });
                          },
                        );
                      },
                      scrollDirection:
                          Axis.vertical, // Change scroll direction to horizontal
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageList(BuildContext context) {
    final imageBloc = ImageBloc(dbHelper: widget.dbHelper);
    imageBloc.add(LoadImagesByTopicId(topicId: _selectedTopicId!));
    return BlocProvider.value(
      value: imageBloc,
      child: Expanded(
          child: ImageListWidget(
        topicId: _selectedTopicId!,
        onBackPressed: _onBackPressed,
        dbHelper: widget.dbHelper,
      )),
    );
  }
}

class TopicCard extends StatelessWidget {
  final Topic topic;
  final DatabaseHelper dbHelper;
  final ValueChanged<int> onCardTap;
  TopicCard(
      {required this.topic, required this.onCardTap, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return _buildTopicCard(context);
  }

  Widget _buildTopicCard(BuildContext context) {
    final imageBloc = ImageBloc(dbHelper: dbHelper);
    imageBloc.add(LoadImagesByTopicId(topicId: topic.id!));
    return BlocProvider.value(
      value: imageBloc,
      child: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageInitial) {
            return CircularProgressIndicator();
          } else if (state is ImagesLoaded) {
            final images = state.images;
            final firstImage = images[0];
            return GestureDetector(
              onTap: () => onCardTap(topic.id!),
              child: Container(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
                margin: EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(firstImage.path),
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.image),
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Text(topic.title,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 0, 0, 0.7))),
                          ),
                          Text(
                              '${firstImage.createdAt.day}/${firstImage.createdAt.month}/${firstImage.createdAt.year}',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF1E1E1E))),
                          Text('${images.length} pages',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF1E1E1E))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Text("Error: Unknown state");
          }
        },
      ),
    );
  }
}


// class TopicStream extends StatefulWidget {
//   final DatabaseHelper dbHelper;

//   TopicStream({required this.dbHelper});

//   @override
//   _TopicStreamState createState() => _TopicStreamState();
// }

// class _TopicStreamState extends State<TopicStream> {
//   int? _selectedTopicId;

//   void _onBackPressed() {
//     setState(() {
//       _selectedTopicId = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if(_selectedTopicId == null) {
//       return StreamBuilder<List<Topic>>(
//         stream: widget.dbHelper.topicStream(),
//         builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//           final topics = snapshot.data!;
//           return Expanded(
//             child: Container(
//               padding: EdgeInsets.only(top: 36),
//               decoration: BoxDecoration(
//                   border: Border(top: BorderSide(color: Colors.black))),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: topics.length,
//                   itemBuilder: (context, index) {
//                     // Create ImageBloc instance here and pass it to the TopicCard
//                     final imageBloc = ImageBloc(dbHelper: widget.dbHelper);
//                     return BlocProvider.value(
//                       value: imageBloc,
//                       child: TopicCard(
//                         topic: topics[index],
//                         onCardTap: (int topicId) {
//                           setState(() {
//                             _selectedTopicId = topicId;
//                           });
//                         },
//                       ),
//                     );
//                   },
//                   scrollDirection:
//                       Axis.vertical, // Change scroll direction to horizontal
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       final imageBloc = ImageBloc(dbHelper: widget.dbHelper);
//       imageBloc.add(LoadImagesByTopicId(topicId: _selectedTopicId!));
//       return BlocProvider.value(
//         value: imageBloc,
//         child: Expanded(child: ImageListWidget(topicId: _selectedTopicId!, onBackPressed: _onBackPressed, dbHelper: widget.dbHelper,)),
//       );
//     }
//   }
// }

// class TopicCard extends StatelessWidget {
//   final Topic topic;
//   final ValueChanged<int> onCardTap;
//   TopicCard({required this.topic, required this.onCardTap});

//   @override
//   Widget build(BuildContext context) {
//     return _buildTopicCard(context);
//   }

//   Widget _buildTopicCard(BuildContext context) {
//     return BlocBuilder<ImageBloc, ImageState>(
//       builder: (context, state) {
//         final imageBloc = context.read<ImageBloc>();
//           imageBloc.add(LoadImagesByTopicId(topicId: topic.id!));
//         if (state is ImageInitial) {
//           return CircularProgressIndicator();
//         } else if (state is ImagesLoaded) {
//           final images = state.images;
//           final firstImage = images[0];

//           return GestureDetector(
//             onTap: () => onCardTap(topic.id!),
//             child: Container(
//               padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
//               margin: EdgeInsets.only(bottom: 14),
//               decoration: BoxDecoration(
//                 color: Color(0xFFF0F0F0),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   images.isNotEmpty
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.file(
//                             File(firstImage.path),
//                             width: 84,
//                             height: 84,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : Icon(Icons.image),
//                   Container(
//                     margin: EdgeInsets.only(left: 12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: EdgeInsets.only(bottom: 12),
//                           child: Text(topic.title,
//                               style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF1E1E1E))),
//                         ),
//                         Text(
//                             '${firstImage.createdAt.day}/${firstImage.createdAt.month}/${firstImage.createdAt.year}',
//                             style: TextStyle(
//                                 fontSize: 14, color: Color(0xFF1E1E1E))),
//                         Text('${images.length} pages',
//                             style: TextStyle(
//                                 fontSize: 14, color: Color(0xFF1E1E1E))),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return Text("Error: Unknown state");
//         }
//       },
//     );
//   }
// }