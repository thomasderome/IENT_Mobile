import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../components/planning.dart';
import '../components/work.dart';
import '../backend/verif_update.dart';

class Home_page extends StatefulWidget {
  const Home_page({super.key});

  @override
  State<Home_page> createState() => _Home_page();
}

class _Home_page extends State<Home_page> {
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  bool _hasCheckedUpdate = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      builder: (context, child) => FTheme(
        data: FThemes.zinc.dark,
        child: child!,
      ),

      home: Builder(
        builder: (innerContext) {
          if (!_hasCheckedUpdate) {
            _hasCheckedUpdate = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              VerifUpdate.check(innerContext);
            });
          }

          return Scaffold(
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
          );
        },
      ),
    );
  }
}