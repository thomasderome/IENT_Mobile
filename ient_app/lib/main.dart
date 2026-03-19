import 'package:flutter/material.dart';
import 'page/login_page.dart';
import 'page/home_page.dart';
import '../backend/backend.dart' as back;
import 'package:flutter_keystore/flutter_keystore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final API = back.API();

  final FlutterKeystore keystore = FlutterKeystore();

  String? username = await keystore.read("username");
  String? password = await keystore.read("password");

  if (username != null && password != null) {
    bool verif = await API.login(username, password);

    if (verif) {runApp(const Home_page());}
    else {runApp(const Login_page());}

  } else {runApp(const Login_page());}
}
