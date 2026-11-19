// Disabled along with the local SQLite NotesService (lib/services/crud/), which was
// replaced by FirebaseCloudStorage. Uncomment together with that service to restore.
void main() {}

// import 'package:notiva/services/crud/crud_constants.dart';
// import 'package:notiva/services/crud/crud_exceptions.dart';
// import 'package:notiva/services/crud/notes_service.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:test/test.dart';

// void main() {
//   setUpAll(() {
//     sqfliteFfiInit();
//     databaseFactory = databaseFactoryFfiNoIsolate;
//   });

//   late NotesService service;

//   setUp(() async {
//     service = NotesService();
//     await service.open(path: inMemoryDatabasePath);
//   });

//   tearDown(() async {
//     await service.close();
//   });

//   group('Database lifecycle', () {
//     test('Cannot open twice', () {
//       expect(
//         service.open(path: inMemoryDatabasePath),
//         throwsA(isA<DatabaseAlreadyOpenException>()),
//       );
//     });

//     test('open(email:) creates and loads the user', () async {
//       // Reopen the shared service so tearDown closes this instance.
//       await service.close();
//       service = NotesService();
//       await service.open(path: inMemoryDatabasePath, email: 'Foo@Bar.com');

//       final user = await service.getUser(email: 'foo@bar.com');
//       expect(user.email, 'foo@bar.com');
//       expect(await service.getOrCreateUser(email: 'foo@bar.com'), user);
//     });

//     test('NotesService is a shared instance', () {
//       expect(identical(NotesService(), service), isTrue);
//     });

//     test('Closing an already-closed database throws', () async {
//       await service.close();
//       await expectLater(
//         service.close(),
//         throwsA(isA<DatabaseIsNotOpenException>()),
//       );
//       // Reopen so tearDown has something to close.
//       await service.open(path: inMemoryDatabasePath);
//     });
//   });

//   group('Users', () {
//     test('Creates a user with a normalised email', () async {
//       final user = await service.createUser(email: 'Foo@Bar.com');
//       expect(user.email, 'foo@bar.com');
//     });

//     test('Looks users up case-insensitively', () async {
//       final created = await service.createUser(email: 'foo@bar.com');
//       final found = await service.getUser(email: 'FOO@bar.COM');
//       expect(found, created);
//     });

//     test('Rejects a duplicate user', () async {
//       await service.createUser(email: 'foo@bar.com');
//       expect(
//         service.createUser(email: 'Foo@bar.com'),
//         throwsA(isA<UserAlreadyExistsException>()),
//       );
//     });

//     test('Throws when a user is missing', () {
//       expect(
//         service.getUser(email: 'nobody@bar.com'),
//         throwsA(isA<CouldNotFindUserException>()),
//       );
//     });

//     test('getOrCreateUser creates once, then returns the same user', () async {
//       final first = await service.getOrCreateUser(email: 'foo@bar.com');
//       final second = await service.getOrCreateUser(email: 'FOO@bar.com');
//       expect(second, first);
//     });

//     test('Deleting a missing user throws', () {
//       expect(
//         service.deleteUser(email: 'nobody@bar.com'),
//         throwsA(isA<CouldNotDeleteUserException>()),
//       );
//     });
//   });

//   group('Notes', () {
//     late DatabaseUser owner;

//     setUp(() async {
//       owner = await service.createUser(email: 'owner@bar.com');
//     });

//     test('Creates an empty, unsynced note', () async {
//       final note = await service.createNote(owner: owner);
//       expect(note.text, '');
//       expect(note.isSyncedWithCloud, false);
//       expect(await service.getNote(id: note.id), note);
//     });

//     test('Cannot create a note for a user that is not in the database', () {
//       const ghost = DatabaseUser(id: 999, email: 'ghost@bar.com');
//       expect(
//         service.createNote(owner: ghost),
//         throwsA(isA<CouldNotFindUserException>()),
//       );
//     });

//     test('Updates note text', () async {
//       final note = await service.createNote(owner: owner);
//       final updated = await service.updateNote(note: note, text: 'hello');
//       expect(updated.text, 'hello');
//       expect(updated.isSyncedWithCloud, false);
//     });

//     test('Updating a missing note throws', () {
//       final missing = DatabaseNote(
//         id: 999,
//         userId: owner.id,
//         text: '',
//         isSyncedWithCloud: false,
//       );
//       expect(
//         service.updateNote(note: missing, text: 'x'),
//         throwsA(isA<CouldNotUpdateNoteException>()),
//       );
//     });

//     test('Deletes a note', () async {
//       final note = await service.createNote(owner: owner);
//       await service.deleteNote(id: note.id);
//       expect(
//         service.getNote(id: note.id),
//         throwsA(isA<CouldNotFindNoteException>()),
//       );
//       expect(
//         service.deleteNote(id: note.id),
//         throwsA(isA<CouldNotDeleteNoteException>()),
//       );
//     });

//     test('Notes are scoped per user', () async {
//       final other = await service.createUser(email: 'other@bar.com');
//       await service.createNote(owner: owner);
//       await service.createNote(owner: owner);
//       await service.createNote(owner: other);

//       expect(await service.getAllNotes(owner: owner), hasLength(2));
//       expect(await service.getAllNotes(owner: other), hasLength(1));

//       expect(await service.deleteAllNotes(owner: owner), 2);
//       expect(await service.getAllNotes(owner: owner), isEmpty);
//       expect(await service.getAllNotes(owner: other), hasLength(1));
//     });

//     test('Deleting a user cascades to their notes', () async {
//       final note = await service.createNote(owner: owner);
//       await service.deleteUser(email: owner.email);
//       expect(
//         service.getNote(id: note.id),
//         throwsA(isA<CouldNotFindNoteException>()),
//       );
//     });

//     test('Sync flag lifecycle', () async {
//       final note = await service.createNote(owner: owner);
//       expect(await service.getUnsyncedNotes(owner: owner), [note]);

//       await service.markNoteSynced(id: note.id);
//       expect((await service.getNote(id: note.id)).isSyncedWithCloud, true);
//       expect(await service.getUnsyncedNotes(owner: owner), isEmpty);

//       await service.updateNote(note: note, text: 'edited');
//       expect(await service.getUnsyncedNotes(owner: owner), [note]);
//     });
//   });

//   group('DatabaseNote.fromRow', () {
//     test('Treats NULL text as an empty string', () {
//       final note = DatabaseNote.fromRow({
//         idColumn: 1,
//         userIdColumn: 1,
//         textColumn: null,
//         isSyncedWithCloudColumn: 0,
//       });
//       expect(note.text, '');
//       expect(note.isSyncedWithCloud, false);
//     });
//   });
// }
