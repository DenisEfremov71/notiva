import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notiva/services/cloud/cloud_note.dart';
import 'package:notiva/services/cloud/cloud_storage_constants.dart';
import 'package:notiva/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // Lazy: this singleton is created before Firebase.initializeApp() runs.
  late final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }

  /// Deletes every note owned by [ownerUserId].
  Future<void> deleteAllNotes({required String ownerUserId}) async {
    // Firestore allows at most 500 operations per batch.
    const batchLimit = 500;
    try {
      final snapshot = await notes.where(ownerUserIdFieldName, isEqualTo: ownerUserId).get();
      final docs = snapshot.docs;
      for (var start = 0; start < docs.length; start += batchLimit) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (start + batchLimit < docs.length) ? start + batchLimit : docs.length;
        for (final doc in docs.sublist(start, end)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (_) {
      throw CouldNotDeleteAllNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  // Filter in Firestore, not on the device: the security rules only allow
  // reading your own notes, so an unfiltered query would be rejected.
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) => notes
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => CloudNote.fromSnapshot(doc)));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (_) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
