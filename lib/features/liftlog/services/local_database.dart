import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../models/lift_entry.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<Database> get _db async {
    if (kIsWeb) throw UnsupportedError('SQLite se usa en la aplicación móvil.');
    if (_database != null) return _database!;
    final databasePath = path.join(await getDatabasesPath(), 'liftlog_pro.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            weekly_goal INTEGER NOT NULL DEFAULT 4
          )
        ''');
        await database.execute('''
          CREATE TABLE exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            muscle_group TEXT NOT NULL,
            day TEXT NOT NULL,
            sets INTEGER NOT NULL,
            reps INTEGER NOT NULL,
            weight REAL NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await database.execute('''
          CREATE TABLE weight_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            weight REAL NOT NULL,
            recorded_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await database.execute('''
          CREATE TABLE progress_photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            image_bytes BLOB NOT NULL,
            captured_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await database.execute('''
          CREATE TABLE workout_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            routine_name TEXT NOT NULL,
            exercises_total INTEGER NOT NULL,
            exercises_done INTEGER NOT NULL,
            completed_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await database.execute('''
          CREATE TABLE workout_lifts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            routine_name TEXT NOT NULL,
            exercise_name TEXT NOT NULL,
            muscle_group TEXT NOT NULL,
            sets INTEGER NOT NULL,
            reps INTEGER NOT NULL,
            weight REAL NOT NULL,
            completed_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<Map<String, Object?>>> _webRows(String key) async {
    final value = (await _prefs).getString(key);
    if (value == null) return [];
    final rows = jsonDecode(value) as List<dynamic>;
    return rows.map((row) => Map<String, Object?>.from(row as Map)).toList();
  }

  Future<void> _saveWebRows(String key, List<Map<String, Object?>> rows) async {
    await (await _prefs).setString(key, jsonEncode(rows));
  }

  String _makeSalt() => List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  String _hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<AppUser?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    if (await getUserByEmail(cleanEmail) != null) return null;
    final salt = _makeSalt();
    final row = <String, Object?>{
      'name': name.trim(),
      'email': cleanEmail,
      'password_hash': _hashPassword(password, salt),
      'password_salt': salt,
      'weekly_goal': 4,
    };
    int id;
    if (kIsWeb) {
      final users = await _webRows('users');
      id =
          users.fold<int>(
            0,
            (largest, user) => max(largest, user['id'] as int),
          ) +
          1;
      users.add({...row, 'id': id});
      await _saveWebRows('users', users);
    } else {
      id = await (await _db).insert('users', row);
    }
    await (await _prefs).setInt('active_user_id', id);
    return AppUser(id: id, name: name.trim(), email: cleanEmail, weeklyGoal: 4);
  }

  Future<Map<String, Object?>?> getUserByEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (kIsWeb) {
      final users = await _webRows('users');
      for (final user in users) {
        if (user['email'] == cleanEmail) return user;
      }
      return null;
    }
    final rows = await (await _db).query(
      'users',
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<AppUser?> loginUser(String email, String password) async {
    final row = await getUserByEmail(email);
    if (row == null) return null;
    final salt = row['password_salt'] as String;
    if (row['password_hash'] != _hashPassword(password, salt)) return null;
    await (await _prefs).setInt('active_user_id', row['id'] as int);
    return AppUser.fromMap(row);
  }

  Future<AppUser?> currentUser() async {
    final id = (await _prefs).getInt('active_user_id');
    if (id == null) return null;
    if (kIsWeb) {
      final users = await _webRows('users');
      for (final user in users) {
        if (user['id'] == id) return AppUser.fromMap(user);
      }
      return null;
    }
    final rows = await (await _db).query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<void> logout() async {
    await (await _prefs).remove('active_user_id');
  }

  Future<void> updateUser(AppUser user) async {
    if (kIsWeb) {
      final users = await _webRows('users');
      final index = users.indexWhere((row) => row['id'] == user.id);
      if (index != -1) {
        users[index]['name'] = user.name;
        users[index]['weekly_goal'] = user.weeklyGoal;
        await _saveWebRows('users', users);
      }
      return;
    }
    await (await _db).update(
      'users',
      {'name': user.name, 'weekly_goal': user.weeklyGoal},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<bool> isDarkMode() async =>
      (await _prefs).getBool('dark_mode') ?? false;

  Future<void> setDarkMode(bool enabled) async {
    await (await _prefs).setBool('dark_mode', enabled);
  }

  Future<List<LiftEntry>> getExercises(int userId, {String? day}) async {
    if (kIsWeb) {
      final rows = await _webRows('exercises');
      return rows
          .where(
            (row) =>
                row['user_id'] == userId && (day == null || row['day'] == day),
          )
          .map(LiftEntry.fromMap)
          .toList();
    }
    final rows = await (await _db).query(
      'exercises',
      where: day == null ? 'user_id = ?' : 'user_id = ? AND day = ?',
      whereArgs: day == null ? [userId] : [userId, day],
      orderBy: 'day, name',
    );
    return rows.map(LiftEntry.fromMap).toList();
  }

  Future<LiftEntry> saveExercise(int userId, LiftEntry entry) async {
    final values = entry.toMap()..remove('id');
    values['user_id'] = userId;
    if (kIsWeb) {
      final rows = await _webRows('exercises');
      if (entry.id == null) {
        final id =
            rows.fold<int>(
              0,
              (largest, row) => max(largest, row['id'] as int),
            ) +
            1;
        rows.add({...values, 'id': id});
        await _saveWebRows('exercises', rows);
        return entry.copyWith(id: id);
      }
      final index = rows.indexWhere(
        (row) => row['id'] == entry.id && row['user_id'] == userId,
      );
      if (index != -1) rows[index] = {...values, 'id': entry.id};
      await _saveWebRows('exercises', rows);
      return entry;
    }
    final database = await _db;
    if (entry.id == null) {
      return entry.copyWith(id: await database.insert('exercises', values));
    }
    await database.update(
      'exercises',
      values,
      where: 'id = ? AND user_id = ?',
      whereArgs: [entry.id, userId],
    );
    return entry;
  }

  Future<void> deleteExercise(int userId, int id) async {
    if (kIsWeb) {
      final rows = await _webRows('exercises');
      rows.removeWhere((row) => row['id'] == id && row['user_id'] == userId);
      await _saveWebRows('exercises', rows);
      return;
    }
    await (await _db).delete(
      'exercises',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteRoutine(int userId, String day) async {
    if (kIsWeb) {
      final rows = await _webRows('exercises');
      final oldLength = rows.length;
      rows.removeWhere((row) => row['user_id'] == userId && row['day'] == day);
      await _saveWebRows('exercises', rows);
      return oldLength - rows.length;
    }
    return (await _db).delete(
      'exercises',
      where: 'user_id = ? AND day = ?',
      whereArgs: [userId, day],
    );
  }

  Future<List<Map<String, Object?>>> getWeightRecords(int userId) async {
    if (kIsWeb) {
      final rows = (await _webRows('weight_records'))
          .where((row) => row['user_id'] == userId)
          .toList();
      rows.sort(
        (a, b) =>
            (b['recorded_at'] as String).compareTo(a['recorded_at'] as String),
      );
      return rows;
    }
    return (await _db).query(
      'weight_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'recorded_at DESC',
    );
  }

  Future<void> addWeightRecord(int userId, double weight) async {
    final row = <String, Object?>{
      'user_id': userId,
      'weight': weight,
      'recorded_at': DateTime.now().toIso8601String(),
    };
    if (kIsWeb) {
      final rows = await _webRows('weight_records');
      final id =
          rows.fold<int>(
            0,
            (largest, value) => max(largest, value['id'] as int),
          ) +
          1;
      rows.add({...row, 'id': id});
      await _saveWebRows('weight_records', rows);
      return;
    }
    await (await _db).insert('weight_records', row);
  }

  Future<void> deleteWeightRecord(int userId, int id) async {
    if (kIsWeb) {
      final rows = await _webRows('weight_records');
      rows.removeWhere((row) => row['id'] == id && row['user_id'] == userId);
      await _saveWebRows('weight_records', rows);
      return;
    }
    await (await _db).delete(
      'weight_records',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<Map<String, Object?>>> getProgressPhotos(int userId) async {
    if (kIsWeb) {
      final rows = (await _webRows('progress_photos'))
          .where((row) => row['user_id'] == userId)
          .toList();
      rows.sort(
        (a, b) =>
            (b['captured_at'] as String).compareTo(a['captured_at'] as String),
      );
      return rows
          .map(
            (row) => {
              ...row,
              'image_bytes': base64Decode(row['image_base64'] as String),
            },
          )
          .toList();
    }
    return (await _db).query(
      'progress_photos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'captured_at DESC',
    );
  }

  Future<void> addProgressPhoto(int userId, Uint8List bytes) async {
    final capturedAt = DateTime.now().toIso8601String();
    if (kIsWeb) {
      final rows = await _webRows('progress_photos');
      final id =
          rows.fold<int>(0, (largest, row) => max(largest, row['id'] as int)) +
          1;
      rows.add({
        'id': id,
        'user_id': userId,
        'image_base64': base64Encode(bytes),
        'captured_at': capturedAt,
      });
      await _saveWebRows('progress_photos', rows);
      return;
    }
    await (await _db).insert('progress_photos', {
      'user_id': userId,
      'image_bytes': bytes,
      'captured_at': capturedAt,
    });
  }

  Future<void> deleteProgressPhoto(int userId, int id) async {
    if (kIsWeb) {
      final rows = await _webRows('progress_photos');
      rows.removeWhere((row) => row['id'] == id && row['user_id'] == userId);
      await _saveWebRows('progress_photos', rows);
      return;
    }
    await (await _db).delete(
      'progress_photos',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<void> recordWorkout(
    int userId,
    String day,
    List<LiftEntry> exercises,
    List<bool> completed,
  ) async {
    final completedCount = completed.where((done) => done).length;
    final completedAt = DateTime.now().toIso8601String();
    final row = <String, Object?>{
      'user_id': userId,
      'routine_name': day,
      'exercises_total': exercises.length,
      'exercises_done': completedCount,
      'completed_at': completedAt,
    };
    if (kIsWeb) {
      final rows = await _webRows('workout_sessions');
      final id =
          rows.fold<int>(
            0,
            (largest, value) => max(largest, value['id'] as int),
          ) +
          1;
      rows.add({...row, 'id': id});
      await _saveWebRows('workout_sessions', rows);
      final lifts = await _webRows('workout_lifts');
      for (var index = 0; index < exercises.length; index++) {
        if (!completed[index]) continue;
        final exercise = exercises[index];
        final liftId =
            lifts.fold<int>(
              0,
              (largest, value) => max(largest, value['id'] as int),
            ) +
            1;
        lifts.add({
          'id': liftId,
          'user_id': userId,
          'routine_name': day,
          'exercise_name': exercise.name,
          'muscle_group': exercise.muscleGroup,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'weight': exercise.weight,
          'completed_at': completedAt,
        });
      }
      await _saveWebRows('workout_lifts', lifts);
      return;
    }
    final database = await _db;
    await database.transaction((transaction) async {
      await transaction.insert('workout_sessions', row);
      for (var index = 0; index < exercises.length; index++) {
        if (!completed[index]) continue;
        final exercise = exercises[index];
        await transaction.insert('workout_lifts', {
          'user_id': userId,
          'routine_name': day,
          'exercise_name': exercise.name,
          'muscle_group': exercise.muscleGroup,
          'sets': exercise.sets,
          'reps': exercise.reps,
          'weight': exercise.weight,
          'completed_at': completedAt,
        });
      }
    });
  }

  Future<List<Map<String, Object?>>> getLiftHistory(int userId) async {
    if (kIsWeb) {
      final rows = (await _webRows('workout_lifts'))
          .where((row) => row['user_id'] == userId)
          .toList();
      rows.sort(
        (a, b) => (b['completed_at'] as String).compareTo(
          a['completed_at'] as String,
        ),
      );
      return rows;
    }
    return (await _db).query(
      'workout_lifts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );
  }

  Future<List<int>> getWeeklyActivity(int userId) async {
    final List<Map<String, Object?>> rows;
    if (kIsWeb) {
      rows = (await _webRows('workout_sessions'))
          .where((row) => row['user_id'] == userId)
          .toList();
    } else {
      rows = await (await _db).query(
        'workout_sessions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    final today = DateTime.now();
    final firstDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));
    final activity = List<int>.filled(7, 0);
    for (final row in rows) {
      final date = DateTime.parse(row['completed_at'] as String);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final index = dateOnly.difference(firstDay).inDays;
      if (index >= 0 && index < 7) activity[index]++;
    }
    return activity;
  }
}
