import 'package:flutter/material.dart';
import 'page/login_page.dart';
import 'page/home_page.dart';
import '../backend/backend.dart' as back;

void main() {
  back.API();
  runApp(const Home_page());
  //runApp(const Login_page());
}
