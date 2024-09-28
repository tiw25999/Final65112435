import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'plantDB.db';
  static const _dbVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create table for plants
    await db.execute('''
      CREATE TABLE plants (
        plantID INTEGER PRIMARY KEY AUTOINCREMENT,
        plantName TEXT NOT NULL,
        plantScientific TEXT,
        plantImage TEXT
      )
    ''');

    // Create table for plant components, and link them to the plants
    await db.execute('''
      CREATE TABLE plantComponent (
        componentID INTEGER PRIMARY KEY AUTOINCREMENT,
        componentName TEXT NOT NULL,
        componentIcon TEXT,
        plantID INTEGER NOT NULL,
        FOREIGN KEY (plantID) REFERENCES plants (plantID)
      )
    ''');

    // Create table for land use types
    await db.execute('''
      CREATE TABLE LandUseType (
        LandUseTypeID INTEGER PRIMARY KEY AUTOINCREMENT,
        LandUseTypeName TEXT NOT NULL,
        LandUseTypeDescription TEXT
      )
    ''');

    // Create table to link plants with land use types
    await db.execute('''
      CREATE TABLE PlantLandUse (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plantID INTEGER NOT NULL,
        LandUseTypeID INTEGER NOT NULL,
        FOREIGN KEY (plantID) REFERENCES plants (plantID),
        FOREIGN KEY (LandUseTypeID) REFERENCES LandUseType (LandUseTypeID)
      )
    ''');
  }

  // CRUD operations for plants
  Future<List<Map<String, dynamic>>> queryAllPlants() async {
    Database db = await instance.database;
    return await db.query('plants');
  }

  Future<int> insertPlant(Map<String, dynamic> plant) async {
    Database db = await instance.database;
    return await db.insert('plants', plant);
  }

  Future<int> updatePlant(int id, Map<String, dynamic> plant) async {
    Database db = await instance.database;
    return await db.update(
      'plants',
      plant,
      where: 'plantID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePlant(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'plants',
      where: 'plantID = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for plant components
  Future<List<Map<String, dynamic>>> queryAllComponents() async {
    Database db = await instance.database;
    return await db.query('plantComponent');
  }

  Future<int> insertComponent(Map<String, dynamic> component) async {
    Database db = await instance.database;
    return await db.insert('plantComponent', component);
  }

  Future<int> updateComponent(int id, Map<String, dynamic> component) async {
    Database db = await instance.database;
    return await db.update(
      'plantComponent',
      component,
      where: 'componentID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteComponent(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'plantComponent',
      where: 'componentID = ?',
      whereArgs: [id],
    );
  }

  // Query components by plant ID
  Future<List<Map<String, dynamic>>> queryComponentsByPlantID(
      int plantID) async {
    Database db = await instance.database;
    return await db.query(
      'plantComponent',
      where: 'plantID = ?',
      whereArgs: [plantID],
    );
  }

  // CRUD operations for land use types
  Future<List<Map<String, dynamic>>> queryAllLandUseTypes() async {
    Database db = await instance.database;
    return await db.query('LandUseType');
  }

  Future<int> insertLandUseType(Map<String, dynamic> landUseType) async {
    Database db = await instance.database;
    return await db.insert('LandUseType', landUseType);
  }

  Future<int> updateLandUseType(
      int id, Map<String, dynamic> landUseType) async {
    Database db = await instance.database;
    return await db.update(
      'LandUseType',
      landUseType,
      where: 'LandUseTypeID = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLandUseType(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'LandUseType',
      where: 'LandUseTypeID = ?',
      whereArgs: [id],
    );
  }

  // Link plants with land use types
  Future<int> insertPlantLandUse(int plantID, int landUseTypeID) async {
    Database db = await instance.database;
    return await db.insert('PlantLandUse', {
      'plantID': plantID,
      'LandUseTypeID': landUseTypeID,
    });
  }

  // Query land use by plant ID
  Future<List<Map<String, dynamic>>> queryLandUseByPlantID(int plantID) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT LandUseType.LandUseTypeName, LandUseType.LandUseTypeDescription
      FROM PlantLandUse
      INNER JOIN LandUseType ON PlantLandUse.LandUseTypeID = LandUseType.LandUseTypeID
      WHERE PlantLandUse.plantID = ?
    ''', [plantID]);
  }

  // เพิ่มฟังก์ชันลบ Land Use
  Future<int> deleteLandUse(int landUseID) async {
    Database db = await instance.database;
    return await db.delete(
      'PlantLandUse',
      where: 'LandUseTypeID = ?',
      whereArgs: [landUseID],
    );
  }
}
