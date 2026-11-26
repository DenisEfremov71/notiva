import 'package:material_ui/material_ui.dart';
import 'package:notiva/extensions/buildcontext/loc.dart';
import 'package:notiva/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {context.loc.ok: null},
  );
}
