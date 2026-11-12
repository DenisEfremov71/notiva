import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/firebase_options.dart';
import 'package:notiva/views/login_view.dart';
import 'package:notiva/views/notes_view.dart';
import 'package:notiva/views/register_view.dart';
import 'package:notiva/views/verify_email_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue)
      ),
      home: const HomePage(),
      routes : {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView()
      }
    )
  );
}

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Created once, so rebuilds don't start initialization again.
  late final Future<void> _initialization = _init();

  Future<void> _init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    // currentUser is cached on the device; reload() fetches the latest
    // state (including emailVerified) from Firebase before build() decides
    // which screen to show.
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      // The account was deleted or disabled: drop the stale session.
      debugPrint('reload failed: ${e.code}');
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
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
      }
    );
  }
}