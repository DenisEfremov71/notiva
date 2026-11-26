import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notiva/extensions/buildcontext/loc.dart';
import 'package:notiva/services/auth/bloc/auth_bloc.dart';
import 'package:notiva/services/auth/bloc/auth_event.dart';
import 'package:notiva/services/auth/bloc/auth_state.dart';
import 'package:notiva/utilities/dialogs/error_dialog.dart';
import 'package:notiva/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const new({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
            if (state is AuthStateForgotPassword) {
              if (state.hasSentEmail) {
                _controller.clear();
                await showPasswordResetSentDialog(context);
              }
              if (state.exception != null) {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  context.loc.forgot_password_view_generic_error,
                );
              }
            }
          },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
          title: Text(context.loc.forgot_password),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(context.loc.forgot_password_view_prompt),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: context.loc.email_text_field_placeholder,
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                },
                child: Text(context.loc.forgot_password_view_send_me_link),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: Text(context.loc.forgot_password_view_back_to_login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
