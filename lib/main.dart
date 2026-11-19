import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notiva/constants/routes.dart';
import 'package:notiva/services/auth/auth_service.dart';
import 'package:notiva/views/login_view.dart';
import 'package:notiva/views/notes/create_update_note_view.dart';
import 'package:notiva/views/notes/notes_view.dart';
import 'package:notiva/views/register_view.dart';
import 'package:notiva/views/verify_email_view.dart';

import 'dart:developer' as devtools show log;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

// class HomePage extends StatefulWidget {
//   const new({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Created once, so rebuilds don't start initialization again.
//   late final Future<void> _initialization = AuthService.firebase().initialize();

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initialization,
//       builder:
//           (
//             context,
//             asyncSnapshot,
//           ) {
//             switch (asyncSnapshot.connectionState) {
//               case ConnectionState.done:
//                 final user = AuthService.firebase().currentUser;
//                 devtools.log(user.toString());
//                 if (user != null) {
//                   if (user.isEmailVerified) {
//                     return const NotesView();
//                   } else {
//                     return const VerifyEmailView();
//                   }
//                 } else {
//                   return const LoginView();
//                 }
//               default:
//                 return const CircularProgressIndicator();
//             }
//           },
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
          title: const Text('Testing bloc'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener:
              (
                context,
                state,
              ) {
                _controller.clear();
              },
          builder:
              (
                context,
                state,
              ) {
                final invalidValue = (state is CounterStateInvalid) ? state.invalidValue : '';
                return Column(
                  children: [
                    Text('Current value => ${state.value}'),
                    Visibility(
                      visible: state is CounterStateInvalid,
                      child: Text('Invalid input: $invalidValue'),
                    ),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Enter a number'),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                          },
                          child: const Text('-'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                          },
                          child: const Text('+'),
                        ),
                      ],
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(super.value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;
  const CounterStateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(super.value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(super.value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>((
      event,
      emit,
    ) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value + integer));
      }
    });
    on<DecrementEvent>((
      event,
      emit,
    ) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value - integer));
      }
    });
  }
}
