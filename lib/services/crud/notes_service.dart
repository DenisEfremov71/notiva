import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:notiva/services/crud/crud_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:notiva/services/crud/crud_exceptions.dart';

class NotesService {

  Database? _db;
  DatabaseUser? _currentUser;
  List<DatabaseNote> _notes = [];
  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Future<void> _cacheNotes({required DatabaseUser owner}) async {
    final allNotes = await getAllNotes(owner: owner);
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  /// Opens the database. [path] overrides the default location in the
  /// application documents directory (used by tests, e.g. with
  /// `inMemoryDatabasePath`).
  ///
  /// If [email] is given, the matching user is loaded (created on first
  /// login) and their notes are cached. If that fails, the database is
  /// closed again and the error is rethrown.
  Future<void> open({String? path, String? email}) async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final dbPath =
          path ?? join((await getApplicationDocumentsDirectory()).path, dbName);
      _db = await openDatabase(
        dbPath,
        version: dbVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute(createUserTableSQL);
          await db.execute(createNoteTableSQL);
        },
      );
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }

    if (email != null) {
      try {
        await _loadUser(email: email);
      } catch (_) {
        await close();
        rethrow;
      }
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // already open, nothing to do
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    _db = null;
    _currentUser = null;
    _notes = [];
    _notesStreamController.add(const []);
    await db.close();
  }

  // users

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final normalizedEmail = email.toLowerCase();

    try {
      final userId = await db.insert(userTable, {emailColumn: normalizedEmail});
      return DatabaseUser(id: userId, email: normalizedEmail);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw UserAlreadyExistsException();
      }
      rethrow;
    }
  }

  /// Returns the local user for [email], creating it on first login.
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await _ensureDbIsOpen();
    return _loadUser(email: email);
  }

  /// Gets or creates the user for [email] in the already-open database,
  /// makes them the current user and caches their notes.
  Future<DatabaseUser> _loadUser({required String email}) async {
    DatabaseUser user;
    try {
      user = await getUser(email: email);
    } on CouldNotFindUserException {
      user = await createUser(email: email);
    } catch (e) {
      rethrow;
    }
    _currentUser = user;
    await _cacheNotes(owner: user);
    return user;
  }

  /// Deletes the user and, via `ON DELETE CASCADE`, all of their notes.
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteUserException();
    }
  }

  // notes

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: false,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<List<DatabaseNote>> getAllNotes({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      where: '$userIdColumn = ?',
      whereArgs: [owner.id],
    );

    return notes.map(DatabaseNote.fromRow).toList();
  }

  Future<List<DatabaseNote>> getUnsyncedNotes({
    required DatabaseUser owner,
  }) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      where: '$userIdColumn = ? AND $isSyncedWithCloudColumn = 0',
      whereArgs: [owner.id],
    );

    return notes.map(DatabaseNote.fromRow).toList();
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

    final updatedCount = await db.update(
      noteTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: '$idColumn = ? AND $userIdColumn = ?',
      whereArgs: [note.id, note.userId],
    );

    if (updatedCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<void> markNoteSynced({required int id}) async {
    final db = _getDatabaseOrThrow();
    final updatedCount = await db.update(
      noteTable,
      {isSyncedWithCloudColumn: 1},
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (updatedCount == 0) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(
      noteTable,
      where: '$userIdColumn = ?',
      whereArgs: [owner.id],
    );

    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletions;
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() => 'User, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = (map[textColumn] as String?) ?? '',
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
