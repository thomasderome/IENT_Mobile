import 'dart:convert';
import 'package:flutter/material.dart';
import 'page/login_page.dart';
import 'page/home_page.dart';
import '../backend/backend.dart' as back;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final API = back.API();

  final FlutterSecureStorage keystore = FlutterSecureStorage();

  String? account_save = await keystore.read(key: "account");

  if (account_save != null) {
    Map<String, dynamic> account = jsonDecode(account_save);

    bool verif = await API.login(account["login"]!, account["password"]!);

    if (verif) {runApp(const Home_page());}
    else {runApp(const Login_page());}

  } else {runApp(const Login_page());}
}
