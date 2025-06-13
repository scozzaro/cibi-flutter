// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food.dart';
import '../models/diary_entry.dart';
import '../models/sport_activity.dart'; // Nuovo import
import 'package:intl/intl.dart'; // Import aggiunto

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Ottieni il percorso per il database.
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'food_tracker.db');

    // DEBUG: Cancella il database ad ogni avvio per la fase di test
    // Rimuovi questa riga quando l'app è pronta per la produzione
    await deleteDatabase(path);

    // Apri il database.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure, // Add onConfigure for foreign key support
    );
  }

  // Enable foreign key support
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Crea le tabelle nel database.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        caloriesPerUnit REAL NOT NULL DEFAULT 0.0,
        glycemicIndex REAL NOT NULL DEFAULT 0.0  -- Nuovo campo aggiunto qui
      )
    ''');
    await db.execute('''
      CREATE TABLE sport_activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        caloriesBurnedPerMinute REAL NOT NULL DEFAULT 0.0
      )
    ''');
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL, -- 'food' or 'sport'
        foodId INTEGER, -- Nullable
        sportActivityId INTEGER, -- Nullable
        quantity REAL NOT NULL, -- Quantity for food, duration in minutes for sport
        FOREIGN KEY (foodId) REFERENCES foods(id) ON DELETE CASCADE,
        FOREIGN KEY (sportActivityId) REFERENCES sport_activities(id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Operazioni per la tabella 'foods' ---

  Future<int> insertFood(Food food) async {
    final db = await database;
    return await db.insert('foods', food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Food>> getFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return List.generate(maps.length, (i) {
      return Food.fromMap(maps[i]);
    });
  }

  Future<int> updateFood(Food food) async {
    final db = await database;
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Operazioni per la tabella 'sport_activities' ---
  Future<int> insertSportActivity(SportActivity activity) async {
    final db = await database;
    return await db.insert('sport_activities', activity.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SportActivity>> getSportActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sport_activities');
    return List.generate(maps.length, (i) {
      return SportActivity.fromMap(maps[i]);
    });
  }

  Future<int> updateSportActivity(SportActivity activity) async {
    final db = await database;
    return await db.update(
      'sport_activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteSportActivity(int id) async {
    final db = await database;
    return await db.delete(
      'sport_activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // --- Operazioni per la tabella 'diary_entries' ---

  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diary_entries');
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<List<DiaryEntry>> getDiaryEntriesByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC', // Order by time when fetching for a specific date
    );
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Enhanced query with JOIN to get detailed diary entries, with optional date filtering
  Future<List<Map<String, dynamic>>> getDetailedDiaryEntries({String? date, DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<String> whereArgs = [];
    String orderByClause = 'de.date DESC, de.time DESC'; // Default order

    if (date != null && date.isNotEmpty) {
      // Se viene fornita una singola data, filtra per quella data
      whereClause = 'WHERE de.date = ?';
      whereArgs.add(date);
      orderByClause = 'de.time ASC'; // Ordina per ora per una data specifica
    } else if (startDate != null && endDate != null) {
      // Se vengono forniti un intervallo di date, filtra per quell'intervallo
      whereClause = 'WHERE de.date BETWEEN ? AND ?';
      whereArgs.add(DateFormat('yyyy-MM-dd').format(startDate));
      whereArgs.add(DateFormat('yyyy-MM-dd').format(endDate));
      orderByClause = 'de.date ASC, de.time ASC'; // Ordina per data e poi per ora per un intervallo
    }
    // Se sia date che startDate/endDate sono null, restituisce tutte le voci (potrebbe essere molto grande)
    // Se questo comportamento non è desiderato, si potrebbe aggiungere un'asserzione o un errore

    // Join con entrambe le tabelle foods e sport_activities
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT
        de.id,
        de.date,
        de.time,
        de.type,
        de.quantity,
        de.foodId,
        de.sportActivityId,
        f.name AS foodName,
        f.unit AS foodUnit,
        f.caloriesPerUnit,
        f.glycemicIndex, -- Nuovo campo selezionato qui
        sa.name AS sportName,
        sa.caloriesBurnedPerMinute
      FROM
        diary_entries de
      LEFT JOIN
        foods f ON de.foodId = f.id
      LEFT JOIN
        sport_activities sa ON de.sportActivityId = sa.id
      $whereClause
      ORDER BY
        $orderByClause
    ''', whereArgs);
    return result;
  }
}




