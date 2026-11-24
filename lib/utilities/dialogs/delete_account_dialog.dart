import 'package:material_ui/material_ui.dart';

/// Asks the user to confirm account deletion by entering their password.
/// Returns the entered password, or `null` if the user cancelled.
Future<String?> showDeleteAccountDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _DeleteAccountDialog(),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const new();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _password;

  @override
  void initState() {
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your account and all your notes. '
            'Enter your password to confirm.',
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _password,
          builder:
              (
                context,
                value,
                _,
              ) {
                return TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: value.text.isEmpty ? null : () => Navigator.of(context).pop(value.text),
                  child: const Text('Delete'),
                );
              },
        ),
      ],
    );
  }
}
