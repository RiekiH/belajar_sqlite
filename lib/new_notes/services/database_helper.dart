import 'package:belajar_sqlite/new_notes/models/note_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _databaseName = 'notes.db';

  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: ((db, version) async => await db.execute(
            '''CREATE TABLE notes(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              title TEXT NOT NULL, 
              content TEXT NOT NULL,
              lat TEXT,
              long TEXT
              )''',
          )),
      version: _version,
    );
  }

  Future<void> printDatabaseContentss() async {
    try {
      Database database = await _getDatabase();
      List<Map<String, dynamic>> rows = await database.query('notes');
      rows.forEach((row) {
        print(row); // Print each row of the table
      });
    } catch (e) {
      print('Error printing database contents: $e');
    }
  }

  static Future<int> addNote(NoteModel note) async {
    final db = await _getDatabase();
    return await db.insert('notes', note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateNote(NoteModel note) async {
    final db = await _getDatabase();
    return await db.update('notes', note.toJson(),
        where: 'id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteNote(NoteModel note) async {
    final db = await _getDatabase();
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<List<NoteModel>?> getAllNotes() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('notes');

    if (maps.isEmpty) {
      return null;
    }

    return List.generate(maps.length, (index) => NoteModel.fromJson(maps[index]));
  }

  // ! Danger
  Future<void> deleteDatabase() async {
    String pathLocation = await getDatabasesPath();
    return databaseFactory.deleteDatabase(pathLocation.toString());
  }
}
