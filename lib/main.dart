import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/helpers/loading/loading_screen.dart';
import 'package:notiva/services/auth/bloc/auth_bloc.dart';
import 'package:notiva/services/auth/bloc/auth_event.dart';
import 'package:notiva/services/auth/bloc/auth_state.dart';
import 'package:notiva/services/auth/firebase_auth_provider.dart';
import 'package:notiva/views/forgot_password_view.dart';
import 'package:notiva/views/login_view.dart';
import 'package:notiva/views/notes/create_update_note_view.dart';
import 'package:notiva/views/notes/notes_view.dart';
import 'package:notiva/views/register_view.dart';
import 'package:notiva/views/verify_email_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Notiva',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
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
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener:
          (
            context,
            state,
          ) {
            if (state.isLoading) {
              LoadingScreen().show(
                context: context,
                message: state.loadingText ?? 'Please wait a moment',
              );
            } else {
              LoadingScreen().hide();
            }
          },
      builder:
          (
            context,
            state,
          ) {
            if (state is AuthStateLoggedIn) {
              return const NotesView();
            } else if (state is AuthStateNeedsVerification) {
              return const VerifyEmailView();
            } else if (state is AuthStateLoggedOut) {
              return const LoginView();
            } else if (state is AuthStateForgotPassword) {
              return const ForgotPasswordView();
            } else if (state is AuthStateRegistering) {
              return const RegisterView();
            } else {
              return const Scaffold(
                body: CircularProgressIndicator(),
              );
            }
          },
    );
  }
}
