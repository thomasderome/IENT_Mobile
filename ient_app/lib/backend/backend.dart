import 'request.dart';
import 'html_parser.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class API {
  // Single skeleton
  static final API _instance = API._internal();
  factory API() {return _instance;}
  API._internal();

  // Instantiate request and parser html
  final HttpRequest request = HttpRequest();
  final HtmlParser parser = HtmlParser();

  // Variable system
  final base_url = "ient.fr";

  // Login function
  Future<bool> login(String username, String password) async {
    Response response = await request.get("https://auth.ient.fr/cas/login?service=https%3A%2F%2Fwww.ient.fr%2Flogin%3Fprofil%3D2", Options());
    final login_page = await parser.html_parse(response.data);

    Map<String, String> params = {
      "user": username,
      "password": password,
      "lmhidden_service": login_page.getElementById("lmhidden_service")?.attributes["value"] ?? "",
      "timezone": "1",
      "skin": "ient",
      "url": ""
    };

    // Change url if add for account parent
    Response login = await request.post("https://auth.ient.fr/cas/login?service=https%3A%2F%2Fwww.ient.fr%2Flogin%3Fprofil%3D2", params, Options(contentType: "application/x-www-form-urlencoded"));
    String redirect_url = login.headers.value("location") ?? "";
    Response verif = await request.redirect_system(redirect_url);

    if (verif.realUri.toString() == "https://www.ient.fr/Welcome") return true;
    return false;
  }

  Future<String> get_planning({String date = "", String link = ""}) async {
    // 2026-02-16
    final login = await request.get(link, Options());
    debugPrint(login.isRedirect.toString());
    debugPrint(login.redirects.toString());

    final response = await request.get("https://www.ient.fr/planninghebdo?date=$date", Options());
    final planning_parse = await parser.html_parse(response.data);

    return "test";
  }
}