import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';

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
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version to handle schema changes
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            firstName TEXT, 
            lastName TEXT, 
            email TEXT UNIQUE,
            contactNumber TEXT,
            password TEXT,
            dateOfBirth TEXT,
            gender TEXT,
            country TEXT,
            termsAccepted INTEGER,
            profileImagePath TEXT  // Add this line for profile image path
          )
        ''');
        print('Database created at $path');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the new column for profile image path in existing database
          await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT');
        }
      },
    );
  }
  Future<void> updateUserProfileImage(String email, String imagePath) async {
    final db = await database;
    await db.update(
      'users',
      {'profileImagePath': imagePath},
      where: 'email = ?',
      whereArgs: [email],
    );
    print('Inserted successfuly');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    try {
      final db = await database;

      // Hash the password before inserting
      String hashedPassword = BCrypt.hashpw(user['password'], BCrypt.gensalt());
      user['password'] = hashedPassword;

      print('Inserting user: $user'); // Debug print

      await db.insert(
        'users',
        user,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Verify insertion
      List<Map<String, dynamic>> users = await db.query('users');
      print('All users: $users');
    } catch (e) {
      print('Error inserting user: $e');
    }
  }

  Future<void> updateUser(String email, Map<String, dynamic> updatedUser) async {
    try {
      final db = await database;

      // Ensure email is present in the updatedUser map
      updatedUser['email'] = email;

      // Update the user record with new values
      await db.update(
        'users',
        updatedUser,
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase()],
      );

      // Verify update
      List<Map<String, dynamic>> users = await db.query('users', where: 'LOWER(email) = ?', whereArgs: [email.toLowerCase()]);
      print('Updated user: $users');
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> updateUserProfile(
      String email,
      String firstName,
      String lastName,
      String contactNumber,
      String dateOfBirth,
      String gender,
      String country,
      String? profileImagePath) async {
    try {
      final db = await database;

      // Create a map with updated user details
      final updatedUser = {
        'firstName': firstName,
        'lastName': lastName,
        'contactNumber': contactNumber,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'country': country,
        'profileImagePath': profileImagePath,
      };

      // Update the user record with new values
      await db.update(
        'users',
        updatedUser,
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase()],
      );

      // Verify update
      List<Map<String, dynamic>> users = await db.query('users', where: 'LOWER(email) = ?', whereArgs: [email.toLowerCase()]);
      print('Updated user profile: $users');
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<void> updateUserPassword(String email, String hashedPassword) async {
    try {
      final db = await database;

      // Update the password for the user with the specified email
      await db.update(
        'users',
        {'password': hashedPassword},
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase()],
      );

      // Verify update
      List<Map<String, dynamic>> users = await db.query('users', where: 'LOWER(email) = ?', whereArgs: [email.toLowerCase()]);
      print('Updated password for user: $users');
    } catch (e) {
      print('Error updating password: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final db = await database;
      return await db.query('users');
    } catch (e) {
      print('Error retrieving users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase()],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print('Error retrieving user by email: $e');
      return null;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
