import 'package:flutter/material.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/enums/menu_action.dart';
import 'package:notiva/services/auth/auth_service.dart';
import 'package:notiva/utilities/show_logout_dialog.dart';

class NotesView extends StatefulWidget {
  const new({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected:(value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute, 
                      (_) => false
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out')
                )
              ];
            }
          )
        ]
      ),
      body: const Text('Hello, World!')
    );
  }
}