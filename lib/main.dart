import 'package:flutter/material.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/services/auth/auth_service.dart';
import 'package:notiva/views/login_view.dart';
import 'package:notiva/views/notes/create_update_note_view.dart';
import 'package:notiva/views/notes/notes_view.dart';
import 'package:notiva/views/register_view.dart';
import 'package:notiva/views/verify_email_view.dart';

import 'dart:developer' as devtools show log;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Created once, so rebuilds don't start initialization again.
  late final Future<void> _initialization = AuthService.firebase().initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder:
          (
            context,
            asyncSnapshot,
          ) {
            switch (asyncSnapshot.connectionState) {
              case ConnectionState.done:
                final user = AuthService.firebase().currentUser;
                devtools.log(user.toString());
                if (user != null) {
                  if (user.isEmailVerified) {
                    return const NotesView();
                  } else {
                    return const VerifyEmailView();
                  }
                } else {
                  return const LoginView();
                }
              default:
                return const CircularProgressIndicator();
            }
          },
    );
  }
}
