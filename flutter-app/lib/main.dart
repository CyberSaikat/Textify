import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/text_canvas_screen.dart';
import 'blocs/canvas/canvas_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => CanvasBloc(),
        child: const TextCanvasScreen(),
      ),
      builder: (context, child) {
        return BlocProvider(
          create: (_) => CanvasBloc(),
          child: child!,
        );
      },
    );
  }
}
