import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notiva/services/auth/bloc/auth_bloc.dart';
import 'package:notiva/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const new({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Text(
                "We've sent you a verification email. Please open it and verify your account by clicking the link.",
              ),
              const Text("If you haven't received the verification email, tap the button below."),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventSendEmailVerification(),
                  );
                },
                child: const Text('Send email verification'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
                },
                child: const Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
