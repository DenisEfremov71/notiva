import 'package:flutter/material.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/services/auth/auth_exceptions.dart';
import 'package:notiva/services/auth/auth_service.dart';
import 'package:notiva/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login')
      ),
      body: Column(
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
                await AuthService.firebase().logIn(
                  email: email, 
                  password: password
                );
                // We need to make sure the user's email has been verified
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (_) => false
                  );
                } else {
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (_) => false
                  );
                }
              } on InvalidCredentialAuthException catch (_) {
                await showErrorDialog(
                  context, 
                  'Invalid credential'
                );
              } on GenericAuthException catch (_) {
                await showErrorDialog(
                  context, 
                  'Authentication error'
                );
              }

            },
            child: Text('Login')
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (_) => false
              );
            },
            child: Text('Not registered yet? Register here.')
          )
        ],
      ),
    );
  }
}