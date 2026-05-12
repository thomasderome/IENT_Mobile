import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;
import '../components/planning.dart';
import '../components/work.dart';

class Home_page extends StatefulWidget {
  const Home_page({super.key});

  @override
  State<Home_page> createState() => _Home_page();
}

class _Home_page extends State<Home_page> {
  final ThemeData darkTheme = ThemeData(
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Planning(),
                const SizedBox(height: 16),
                const Work(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
