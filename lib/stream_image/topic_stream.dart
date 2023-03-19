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
  TextEditingController _searchController = TextEditingController();

  List<Topic> _searchTopics(List<Topic> topics) {
    String searchQuery = _searchController.text.trim().toLowerCase();
    if (searchQuery.isEmpty) {
      return topics;
    }
    return topics.where((topic) => topic.title.toLowerCase().contains(searchQuery)).toList();
  }

  void _onBackPressed() async {
    setState(() {
      _selectedTopicId = null;
    });
  }

  void initState() {
    super.initState();
    _initializeDatabase();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.initialize();
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _selectedTopicId == null
        ? _buildTopicList(context)
        : _buildImageList(context);
  }


  FocusNode _searchFocusNode = FocusNode();
  Widget _buildTopicList(BuildContext context) {
  _initializeDatabase();
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: _searchFocusNode.hasFocus ? null : 'Search',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        Text(
          "Topic",
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          )
        ),
        Expanded(
          child: StreamBuilder<List<Topic>>(
            stream: widget.dbHelper.topicStream(),
            builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final topics = _searchTopics(snapshot.data!);
              return ListView.builder(
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
              );
            },
          ),
        ),
      ],
    ),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 0, 0, 0.7)),
                            ),
                            width: 220,
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

