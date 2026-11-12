import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notiva/constants/routes.dart';

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
      Navigator.of(context).pushNamedAndRemoveUntil(
        notesRoute,
        (_) => false
      );
    } else {
      _showMessage('Email is not verified yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                onPressed: _sendVerification,
                child: const Text('Send email verification')
              ),
              TextButton(
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