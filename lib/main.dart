import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notiva/firebase_options.dart';
import 'package:notiva/views/login_view.dart';
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
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
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
  // Created once, so rebuilds don't start Firebase initialization again.
  late final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  @override
  void initState() {
    super.initState();
    // Navigate from a callback that runs after Firebase is ready,
    // never from inside build().
    _initialization.then((_) async {
      // currentUser is cached on the device; reload() fetches the latest
      // state (including emailVerified) from Firebase.
      await FirebaseAuth.instance.currentUser?.reload();
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('Signed in as ${user?.email}, emailVerified=${user?.emailVerified}');
      if (!(user?.emailVerified ?? false)) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const VerifyEmailView()
          )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
            //return const Text('Done');
            return const LoginView();
          default:
            return const CircularProgressIndicator();
        }
      }
    );
  }
}
