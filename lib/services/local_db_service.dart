import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/notification_model.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    print('Database path: $path');
 
    bool exists = await databaseExists(path);
    print('Database exists: $exists');
    
    return openDatabase(
      path,
      onCreate: (db, version) {
        print('Creating database tables');
        db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, dueDate TEXT, isCompleted INTEGER)',
        );
        db.execute(
          'CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, payload TEXT, timestamp TEXT, isRead INTEGER)',
        );
        print('Database tables created');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        print('Upgrading database from $oldVersion to $newVersion');
        if (oldVersion < 2) {
    
          db.execute(
            'CREATE TABLE IF NOT EXISTS notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, payload TEXT, timestamp TEXT, isRead INTEGER)',
          );
          print('Notifications table created during upgrade');
        }
      },
      onOpen: (db) {
        print('Database opened');
       
        db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"').then((tables) {
          print('Tables in database: ${tables.map((t) => t['name']).join(', ')}');
        });
      },
      version: 2,
    );
  }

  static Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  static Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert('notifications', notification.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<NotificationModel>> getNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications', 
      orderBy: 'timestamp DESC'
    );
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  static Future<void> markNotificationAsRead(int id) async {
    final db = await database;
    await db.update(
      'notifications', 
      {'isRead': 1}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  static Future<void> deleteNotification(int id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete('notifications');
  }
}
