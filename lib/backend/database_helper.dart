import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_dark.db');
    return await openDatabase(
      path,
      version: 3, // Versão incrementada para incluir novos campos
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        name TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        symptoms TEXT,
        lastUpdate TEXT,
        color TEXT,
        painOrigin TEXT, -- Novo campo
        painLevel REAL -- Novo campo
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE patient_records ADD COLUMN painOrigin TEXT;
      ''');
      await db.execute('''
        ALTER TABLE patient_records ADD COLUMN painLevel REAL;
      ''');
      print(
          "Campos 'painOrigin' e 'painLevel' adicionados à tabela 'patient_records'.");
    }
  }

  // Inserir um usuário
  Future<bool> insertUser(String username, String name, String password) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        {'username': username, 'name': name, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print("Erro ao inserir usuário: $e");
      return false;
    }
  }

  // Verificar usuário e autenticar
  Future<Map<String, dynamic>?> verifyUser(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Salvar usuário logado localmente
  Future<void> saveLoggedUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_user', username);
  }

  // Obter usuário logado
  Future<String?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_user');
  }

  // Obter dados completos do usuário logado
  Future<Map<String, dynamic>?> getLoggedUserData() async {
    final username = await getLoggedUser();
    if (username == null) return null;

    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Inserir um registro de paciente
  Future<bool> insertPatientRecord(
    String name,
    int age,
    String symptoms,
    String lastUpdate,
    String color,
    String painOrigin,
    double painLevel,
  ) async {
    try {
      final db = await database;
      await db.insert(
        'patient_records',
        {
          'name': name,
          'age': age,
          'symptoms': symptoms,
          'lastUpdate': lastUpdate,
          'color': color,
          'painOrigin': painOrigin,
          'painLevel': painLevel,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print("Erro ao salvar registro: $e");
      return false;
    }
  }

  // Obter todos os registros de pacientes
  Future<List<Map<String, dynamic>>> getPatientRecords() async {
    final db = await database;
    return await db.query('patient_records');
  }

  // Deletar registro de paciente
  Future<bool> deletePatientRecord(int id) async {
    try {
      final db = await database;
      final rowsDeleted = await db.delete(
        'patient_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return rowsDeleted > 0;
    } catch (e) {
      print("Erro ao excluir registro: $e");
      return false;
    }
  }

  // Atualizar registro de paciente
  Future<bool> updatePatientRecord(
    int id,
    String name,
    int age,
    String symptoms,
    String lastUpdate,
    String color,
    String painOrigin,
    double painLevel,
  ) async {
    try {
      final db = await database;
      final rowsUpdated = await db.update(
        'patient_records',
        {
          'name': name,
          'age': age,
          'symptoms': symptoms,
          'lastUpdate': lastUpdate,
          'color': color,
          'painOrigin': painOrigin,
          'painLevel': painLevel,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return rowsUpdated > 0;
    } catch (e) {
      print("Erro ao atualizar registro: $e");
      return false;
    }
  }
}
