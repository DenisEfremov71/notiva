import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notiva/firebase_options.dart';
import 'package:notiva/views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple)
      ),
      home: const HomePage(),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Home')
      ),
      body: FutureBuilder(
        future: _initialization,
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              return const Text('Done');
            default:
              return const Text('Loading...');
          }
        }
      )
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const new({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  Future<void> _sendVerification() async {
    try {

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://notiva-flutter.web.app/auth/done',
        handleCodeInApp: false,
        iOSBundleId: 'com.denisefremov.notiva',
        androidPackageName: 'com.denisefremov.notiva',
        androidInstallApp: false,
      );

      await FirebaseAuth.instance.currentUser?.sendEmailVerification(actionCodeSettings);
      if (!mounted) return;
      _showMessage('Verification email sent. Use the link in the newest email.');
    } on FirebaseAuthException catch (e) {
      debugPrint('sendEmailVerification failed: ${e.code} ${e.message}');
      if (!mounted) return;
      _showMessage('Could not send email: ${e.code}');
    }
  }

  Future<void> _checkVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('After reload: emailVerified=${user?.emailVerified}');
    if (!mounted) return;
    if (user?.emailVerified ?? false) {
      _showMessage('Email verified!');
      Navigator.of(context).pop();
    } else {
      _showMessage('Email is not verified yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Verify Email')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Text(
                'Please verify your email address',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                onPressed: _sendVerification,
                child: const Text('Send email verification')
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                onPressed: _checkVerified,
                child: const Text("I've verified my email")
              )
            ]
          ),
        ),
      )
    );
  }
}
