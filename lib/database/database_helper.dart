import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/phone.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'jbiphone_stock.db');

    return await openDatabase(
      path,
      version: 3, // Incremented version number for the schema update
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE phones(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model TEXT NOT NULL,
        imei TEXT NOT NULL UNIQUE,
        purchase_date INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        color TEXT NOT NULL,
        capacity TEXT NOT NULL,
        seller_name TEXT NOT NULL,
        seller_phone TEXT NOT NULL,
        notes TEXT,
        status INTEGER NOT NULL,
        buyer_name TEXT,
        buyer_phone TEXT,
        sale_date INTEGER,
        sale_price REAL,
        service_name TEXT,
        service_center_name TEXT,
        service_center_phone TEXT,
        service_price REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for the color, capacity, seller name and phone
      await db.execute('ALTER TABLE phones ADD COLUMN color TEXT DEFAULT ""');
      await db
          .execute('ALTER TABLE phones ADD COLUMN capacity TEXT DEFAULT ""');
      await db
          .execute('ALTER TABLE phones ADD COLUMN seller_name TEXT DEFAULT ""');
      await db.execute(
          'ALTER TABLE phones ADD COLUMN seller_phone TEXT DEFAULT ""');
    }

    if (oldVersion < 3) {
      // Add new columns for service information
      await db.execute('ALTER TABLE phones ADD COLUMN service_name TEXT');
      await db
          .execute('ALTER TABLE phones ADD COLUMN service_center_name TEXT');
      await db
          .execute('ALTER TABLE phones ADD COLUMN service_center_phone TEXT');
      await db.execute('ALTER TABLE phones ADD COLUMN service_price REAL');
    }
  }

  // CRUD Operations for Phones

  // Create
  Future<int> insertPhone(Phone phone) async {
    final db = await database;
    return await db.insert('phones', phone.toMap());
  }

  // Read
  Future<Phone?> getPhone(int id) async {
    final db = await database;
    final maps = await db.query(
      'phones',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Phone.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Phone>> getAllPhones() async {
    final db = await database;
    final maps = await db.query('phones');

    return List.generate(maps.length, (i) {
      return Phone.fromMap(maps[i]);
    });
  }

  Future<List<Phone>> getPhonesByStatus(PhoneStatus status) async {
    final db = await database;
    final maps = await db.query(
      'phones',
      where: 'status = ?',
      whereArgs: [status.index],
    );

    return List.generate(maps.length, (i) {
      return Phone.fromMap(maps[i]);
    });
  }

  // Update
  Future<int> updatePhone(Phone phone) async {
    final db = await database;
    return await db.update(
      'phones',
      phone.toMap(),
      where: 'id = ?',
      whereArgs: [phone.id],
    );
  }

  // Delete
  Future<int> deletePhone(int id) async {
    final db = await database;
    return await db.delete(
      'phones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Dashboard Statistics
  Future<Map<String, dynamic>> getDailyStats(DateTime date) async {
    final db = await database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as phonesCount,
        SUM(sale_price - (purchase_price + IFNULL(service_price, 0))) as totalProfit,
        SUM(sale_price) as totalRevenue,
        SUM(purchase_price + IFNULL(service_price, 0)) as totalCost
      FROM phones 
      WHERE status = ? AND sale_date BETWEEN ? AND ?
    ''', [PhoneStatus.sold.index, startOfDay, endOfDay]);

    return {
      'phonesCount': result.first['phonesCount'] as int? ?? 0,
      'totalProfit': result.first['totalProfit'] as double? ?? 0.0,
      'totalRevenue': result.first['totalRevenue'] as double? ?? 0.0,
      'totalCost': result.first['totalCost'] as double? ?? 0.0,
    };
  }

  Future<Map<String, dynamic>> getMonthlyStats(int year, int month) async {
    final db = await database;
    final startOfMonth = DateTime(year, month).millisecondsSinceEpoch;
    final endOfMonth =
        DateTime(year, month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as phonesCount,
        SUM(sale_price - (purchase_price + IFNULL(service_price, 0))) as totalProfit,
        SUM(sale_price) as totalRevenue,
        SUM(purchase_price + IFNULL(service_price, 0)) as totalCost
      FROM phones 
      WHERE status = ? AND sale_date BETWEEN ? AND ?
    ''', [PhoneStatus.sold.index, startOfMonth, endOfMonth]);

    return {
      'phonesCount': result.first['phonesCount'] as int? ?? 0,
      'totalProfit': result.first['totalProfit'] as double? ?? 0.0,
      'totalRevenue': result.first['totalRevenue'] as double? ?? 0.0,
      'totalCost': result.first['totalCost'] as double? ?? 0.0,
    };
  }

  Future<Map<String, dynamic>> getYearlyStats(int year) async {
    final db = await database;
    final startOfYear = DateTime(year).millisecondsSinceEpoch;
    final endOfYear =
        DateTime(year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as phonesCount,
        SUM(sale_price - (purchase_price + IFNULL(service_price, 0))) as totalProfit,
        SUM(sale_price) as totalRevenue,
        SUM(purchase_price + IFNULL(service_price, 0)) as totalCost
      FROM phones 
      WHERE status = ? AND sale_date BETWEEN ? AND ?
    ''', [PhoneStatus.sold.index, startOfYear, endOfYear]);

    return {
      'phonesCount': result.first['phonesCount'] as int? ?? 0,
      'totalProfit': result.first['totalProfit'] as double? ?? 0.0,
      'totalRevenue': result.first['totalRevenue'] as double? ?? 0.0,
      'totalCost': result.first['totalCost'] as double? ?? 0.0,
    };
  }

  Future<Map<String, dynamic>> getCurrentInventoryStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as phonesCount,
        SUM(purchase_price + IFNULL(service_price, 0)) as totalCost
      FROM phones 
      WHERE status IN (?, ?)
    ''', [PhoneStatus.inStock.index, PhoneStatus.onService.index]);

    return {
      'phonesCount': result.first['phonesCount'] as int? ?? 0,
      'totalCost': result.first['totalCost'] as double? ?? 0.0,
    };
  }
}
