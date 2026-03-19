import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ient_app/page/home_page.dart';
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

  bool login_waiting = false;
  bool login_success = true;

  @override
  void dispose() {
    _username_controller.dispose();
    _password_controller.dispose();
    super.dispose();
  }

  void Login(BuildContext context) async {
    login_success = true;
    setState(() => login_waiting = true);

    String username = _username_controller.text;
    String password = _password_controller.text;

    bool verif = await API.login(username, password);
    if (verif) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Home_page()));
      }
    }

    setState(() {
      if (!verif) {
        login_waiting = false;
        login_success = false;
      }
    });
  }

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
        home: Builder(
          builder: (new_context) {
            return Scaffold(
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
                      if (!login_success) FAlert(
                        style: FAlertStyle.destructive.call(),
                        title: const Text('Erreur de connection'),
                        icon: Icon(FIcons.circleAlert),
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
                        prefix: login_waiting ? const FCircularProgress() : const Icon(FIcons.logIn),
                        onPress: login_waiting ? null : () => Login(new_context),
                        child: const Text('Se connecter'),
                      ),
                    ],
                  ),
                )
            );
          }
        )
    );
  }
}
