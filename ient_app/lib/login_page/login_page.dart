  import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;

class Login_page extends StatefulWidget {
  const Login_page({super.key});

  @override
  State<Login_page> createState() => _Login_page();
}

class _Login_page extends State<Login_page> {
  final API = back.API();

  final TextEditingController _username_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  @override
  void dispose() {
    _username_controller.dispose();
    _password_controller.dispose();
    super.dispose();
  }

  void Login() async {
    String username = _username_controller.text;
    String password = _password_controller.text;

    bool verif = await API.login(username, password);
    debugPrint("$verif");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.dark,
          child: child!,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text("IENT"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Login page",
                      style: TextStyle(
                          fontSize: 25
                      )
                  ),
                  FTextField(
                    control: .managed(controller: _username_controller),
                    label: const Text("Username:"),
                    hint: "Username",
                    maxLines: 1,

                  ),
                  FTextField.password(
                    control: .managed(controller: _password_controller),
                    label: const Text("Password:"),
                    hint: "Password",
                    maxLines: 1,
                  ),
                  FButton(
                    mainAxisSize: MainAxisSize.min,
                    prefix: const Icon(FIcons.logIn),
                    onPress: Login,
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
    brightness: Brightness.dark,
);
