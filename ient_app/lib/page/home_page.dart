import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;
import '../components/planning.dart';

class Home_page extends StatefulWidget {
  const Home_page({super.key});

  @override
  State<Home_page> createState() => _Home_page();
}

class _Home_page extends State<Home_page> {
  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: darkTheme,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.dark,
          child: child!,
        ),
        home: Scaffold(
            body: Center(
              child: Planning()
            )
        )
    );
  }
}
