import 'dart:io';

import 'package:afaas_news/PostDataModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper.privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper.privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'afaas_news.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT,
        slug TEXT,
        image TEXT        
      )''');
  }

  Future <List<PostDataModel>> getPosts() async {
    Database db = await instance.database;
    var posts = await db.query('posts', orderBy: 'title');
    List<PostDataModel> postList = posts.isNotEmpty ?
        posts.map((e) => PostDataModel.fromMap(e)).toList() : [];

    return postList;
  }

  Future<int> add(PostDataModel post) async {
    Database db = await instance.database;
    return await db.insert('posts', post.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }
}
