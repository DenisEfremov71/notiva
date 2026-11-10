import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notiva/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const new({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Register')
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform
        ),
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email'
                    )
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password'
                    )
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email, 
                          password: password
                        );
                        print(userCredential);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print('Weak password');
                        } else if (e.code == 'email-already-in-use') {
                          print('Email is already in use');
                        } else if (e.code == 'invalid-email') {
                          print('Invalid email');
                        } else {
                          print(e.code);
                        }
                      } catch (e) {
                        print('Something bad happened!');
                        print(e);
                      }

                    },
                    child: Text('Register', style: TextStyle(color: Colors.blue))
                  ),
                ],
              );
            default:
              return const Text('Loading...');
          }
        }
      )
    );
  }
}