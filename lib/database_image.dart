import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseImage {
  static const _databaseName = 'databaseImage.db';
  static const _databaseVersion = 1;

  static const imageTable = 'images';
  static const columnIdImage = 'id_image';
  static const columnImage = 'image';
  static const columnDate = 'date';
  static const columnContent = 'content';

  static const tagTable = 'tags';
  static const columnTag = 'tag';

  DatabaseImage._privateConstructor();
  static DatabaseImage instance = DatabaseImage._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: onCreate);
  }

  Future<void> onCreate(Database db, int version) async {
    // sua lai thanh NOT NULL khi hoan thien app
    return await db.execute('''
      CREATE TABLE $imageTable(
        $columnIdImage INT PRIMARY KEY,
        $columnImage TEXT NOT NULL,
        $columnContent TEXT,
        $columnDate DATE NOT NULL
      );
      CREATE TABLE $tagTable(
        $columnIdImage INT,
        $columnTag TEXT,
        PRIMARY KEY ($columnIdImage, $columnTag),
        FOREIGN KEY ($columnIdImage) REFERENCES $imageTable ($columnIdImage)
      );
    ''');
  }

  Future<int> insertImage(File imageFile) async {
    Database db = await instance.database;
    String path = imageFile.path;
    final DateTime now = DateTime.now();
    final String createAt = now.toIso8601String().split('T')[0];

    return await db
        .insert(imageTable, {columnImage: path, columnDate: createAt});
  }

  Future<List<File>> getImages() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(imageTable);
    List<File> images = [];
    for (Map map in maps) {
      String path = map[columnImage];
      String createAt = map[columnDate];
      print(createAt);
      images.add(File(path));
    }

    return images;
  }

  Future<void> deleteTable() async {
    Database db = await instance.database;
    await db.delete(imageTable);
  }
}
