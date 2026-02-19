import 'package:flutter/material.dart';
import 'login_page/login_page.dart';
import '../backend/backend.dart' as back;

void main() {
  back.API();
  runApp(const Login_page());
}
