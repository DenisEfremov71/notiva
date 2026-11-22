import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notiva/services/auth/auth_exceptions.dart';
import 'package:notiva/services/auth/bloc/auth_bloc.dart';
import 'package:notiva/services/auth/bloc/auth_event.dart';
import 'package:notiva/services/auth/bloc/auth_state.dart';
import 'package:notiva/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener:
          (
            context,
            state,
          ) async {
            if (state is AuthStateRegistering) {
              if (state.exception is WeakPasswordAuthException) {
                await showErrorDialog(context, 'Weak password');
              } else if (state.exception is EmailAlreadyInUseAuthException) {
                await showErrorDialog(context, 'Email is already in use');
              } else if (state.exception is InvalidEmailAuthException) {
                await showErrorDialog(context, 'Invalid email');
              } else if (state.exception is GenericAuthException) {
                await showErrorDialog(context, 'Failed to register');
              }
            }
          },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
          title: const Text('Register'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Enter your email'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(hintText: 'Enter your password'),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                  AuthEventRegister(
                    email,
                    password,
                  ),
                );
              },
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEventLogOut(),
                );
              },
              child: const Text('Already registered? Login here.'),
            ),
          ],
        ),
      ),
    );
  }
}
