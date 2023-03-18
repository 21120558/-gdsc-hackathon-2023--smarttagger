import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class Topic {
  int id;
  String title;

  Topic({required this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  static Topic fromMap(Map<String, dynamic> map) {
    return Topic(id: map['id'], title: map['title']);
  }
}

class ImageModel {
  int? id;
  int topicId;
  String path;
  DateTime createdAt;

  ImageModel(
      {required this.id,
      required this.topicId,
      required this.path,
      required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'path': path,
      'createdAt': createdAt.toIso8601String()
    };
  }

  static ImageModel fromMap(Map<String, dynamic> map) {
    return ImageModel(
        id: map['id'],
        topicId: map['topicId'],
        path: map['path'],
        createdAt: DateTime.parse(map['createdAt']));
  }
}

class DatabaseHelper {
  static final _databaseName = "my_database.db";
  static final _databaseVersion = 1;

  static final tableTopics = 'topics';
  static final tableImages = 'images';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnTopicId = 'topicId';
  static final columnPath = 'path';
  static final columnCreatedAt = 'createdAt';

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableTopics (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableImages (
            $columnId INTEGER PRIMARY KEY,
            $columnTopicId INTEGER NOT NULL,
            $columnPath TEXT NOT NULL,
            $columnCreatedAt TEXT NOT NULL
          )
          ''');
  }

  Future<int> insertTopic(Topic topic) async {
    Database db = await instance.database;
    return await db.insert(tableTopics, topic.toMap());
  }

  Future<int> insertImage(ImageModel image) async {
    Database db = await instance.database;
    return await db.insert(tableImages, image.toMap());
  }

  // Lấy danh sách tất cả các chủ đề
  Future<List<Topic>> getAllTopics() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableTopics);

    return List.generate(maps.length, (i) {
      return Topic.fromMap(maps[i]);
    });
  }

  // Lấy danh sách tất cả các ảnh theo chủ đề
  Future<List<ImageModel>> getImagesByTopicId(int topicId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db
        .query(tableImages, where: '$columnTopicId = ?', whereArgs: [topicId]);

    return List.generate(maps.length, (i) {
      return ImageModel.fromMap(maps[i]);
    });
  }

  Future<void> insertTopicWithImageByName(
    String topicName, File imageFile) async {
    // Check if the topic exists
    Topic? existingTopic = await getTopicByTitle(topicName);
    Topic topic;

    if (existingTopic != null) {
      topic = existingTopic;
    } else {
      Topic newTopic = Topic(id: 0, title: topicName);
      int topicId = await insertTopic(newTopic);
      newTopic.id = topicId;
      topic = newTopic;
    }

    await insertImageWithFile(topic, imageFile);
  }

  // Hàm chuyển đổi File thành ImageModel và thêm vào cơ sở dữ liệu
  Future<int> insertImageWithFile(Topic topic, File imageFile) async {
    // Lưu ảnh vào bộ nhớ thiết bị và lấy đường dẫn
    String imagePath = await _saveImageToFileSystem(imageFile);
    // Tạo đối tượng ImageModel
    ImageModel imageModel = ImageModel(
      id: null, 
      topicId: topic.id,
      path: imagePath,
      createdAt: DateTime.now(),
    );

    return await insertImage(imageModel);
  }

  // Hàm lưu ảnh vào bộ nhớ thiết bị và trả về đường dẫn
  Future<String> _saveImageToFileSystem(File imageFile) async {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = join(directory.path, fileName);

      final buffer = await imageFile.readAsBytes();
      await File(path).writeAsBytes(buffer);

      return path;
  }

  Stream<List<Topic>> topicStream() async* {
    while (true) {
      List<Topic> topics = await getAllTopics();
      yield topics;
      await Future.delayed(
          Duration(seconds: 5)); // Update interval, can be adjusted
    }
  }

  Future<Topic?> getTopicByTitle(String title) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tableTopics,
        where: '$columnTitle = ?', whereArgs: [title]);

    if (maps.isNotEmpty) {
      return Topic.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> deleteAll() async {
    Database db = await instance.database;
    await db.delete(tableImages);
    await db.delete(tableTopics);
  }
}
