import 'package:material_ui/material_ui.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const new({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendVerification() async {
    try {
      await AuthService.firebase().sendEmailVerification();
      if (!mounted) return;
      _showMessage('Verification email sent. Use the link in the newest email.');
    } on Exception {
      if (!mounted) return;
      _showMessage('Could not send verification email. Please try again.');
    }
  }

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
              TextButton(onPressed: _sendVerification, child: const Text('Send email verification')),
              TextButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
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
