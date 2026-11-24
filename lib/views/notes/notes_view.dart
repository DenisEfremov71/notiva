import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/enums/menu_action.dart';
import 'package:notiva/services/auth/auth_exceptions.dart';
import 'package:notiva/services/auth/auth_service.dart';
import 'package:notiva/services/auth/bloc/auth_bloc.dart';
import 'package:notiva/services/auth/bloc/auth_event.dart';
import 'package:notiva/services/auth/bloc/auth_state.dart';
import 'package:notiva/services/cloud/cloud_note.dart';
import 'package:notiva/services/cloud/cloud_storage_exceptions.dart';
import 'package:notiva/services/cloud/firebase_cloud_storage.dart';
import 'package:notiva/utilities/dialogs/delete_account_dialog.dart';
import 'package:notiva/utilities/dialogs/error_dialog.dart';
import 'package:notiva/utilities/dialogs/logout_dialog.dart';
import 'package:notiva/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const new({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  // Read once: after the account is deleted currentUser becomes null, and the
  // view may rebuild before the app switches to the login screen.
  late final String _userId;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _userId = AuthService.firebase().currentUser!.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener:
          (
            context,
            state,
          ) async {
            if (state is AuthStateLoggedIn) {
              final exception = state.exception;
              if (exception == null) return;
              final String message;
              if (exception is InvalidCredentialAuthException) {
                message = 'Incorrect password. Your account was not deleted.';
              } else if (exception is CouldNotDeleteAllNotesException) {
                message = 'Could not delete your notes. Your account was not deleted.';
              } else if (exception is RequiresRecentLoginAuthException) {
                message = 'Please log out, log back in, and try again.';
              } else {
                message = 'Could not delete your account. Please try again.';
              }
              await showErrorDialog(context, message);
            }
          },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
          title: const Text('Your Notes'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      if (!context.mounted) return;
                      context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                    }
                  case MenuAction.deleteAccount:
                    final password = await showDeleteAccountDialog(context);
                    if (password != null) {
                      if (!context.mounted) return;
                      context.read<AuthBloc>().add(
                        AuthEventDeleteAccount(password),
                      );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log out'),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.deleteAccount,
                    child: Text('Delete account'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: _userId),
          builder:
              (
                context,
                snapshot,
              ) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      return NotesListView(
                        notes: allNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(documentId: note.documentId);
                        },
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                            createOrUpdateNoteRoute,
                            arguments: note,
                          );
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  default:
                    return const CircularProgressIndicator();
                }
              },
        ),
      ),
    );
  }
}
