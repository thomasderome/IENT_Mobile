import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class Login_page extends StatefulWidget {
  const Login_page({super.key});

  @override
  State<Login_page> createState() => _Login_page();
}

class _Login_page extends State<Login_page> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: darkTheme,
        home: Scaffold(
            appBar: AppBar(
              title: Text("IENT"),
            ),
            body: Center(
              child: Column(
                children: [
                  const Text("Login page",
                      style: TextStyle(
                          fontSize: 25
                      )
                  ),
                  FTextField(
                    label: const Text("Username:"),
                    hint: "Username",
                    maxLines: 1,

                  ),
                  FTextField.password(
                    label: const Text("Password:"),
                    hint: "Password",
                    maxLines: 1,
                  ),
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    prefix: const Icon(FIcons.logIn),
                    onPress: () => (),
                    child: const Text('Se connecter'),
                  )
                ],
              ),
            )
        )
    );
  }
}

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark
);
