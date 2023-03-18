import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:io';

class TopicStream extends StatelessWidget {
  final DatabaseHelper dbHelper;

  TopicStream({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Topic>>(
      stream: dbHelper.topicStream(),
      builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final topics = snapshot.data!;
        return Expanded(
          child: ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return TopicCard(topic: topics[index], dbHelper: dbHelper);
            },
            scrollDirection:
                Axis.vertical, // Change scroll direction to horizontal
          ),
        );
      },
    );
  }
}

class TopicCard extends StatelessWidget {
  final Topic topic;
  final DatabaseHelper dbHelper;

  TopicCard({required this.topic, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: FutureBuilder<List<ImageModel>>(
        future: dbHelper.getImagesByTopicId(topic.id),
        builder:
            (BuildContext context, AsyncSnapshot<List<ImageModel>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return SizedBox.shrink(); // Empty container
          }
          final images = snapshot.data!;
          return Container(
            child: Row(
              children: [
                Text(topic.title),
                images.isNotEmpty
                    ? Image.file(
                      File(images[0].path),
                      width: 50,
                      height: 50,
                    )
                    : Icon(Icons.image),
              ],
            ),
          );
        },
      ),
    );
  }
}
