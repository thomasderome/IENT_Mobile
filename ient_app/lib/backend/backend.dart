import 'request.dart';
import 'html_parser.dart';
import 'package:flutter/material.dart';

class API {
  final HttpRequest request = HttpRequest();
  final HtmlParser parser = HtmlParser();

  final base_url = "ient.fr";

  String token = "";

  Future<bool> login(String username, String password) async {
    final response = await request.get("https://auth.ient.fr/cas/login?service=https%3A%2F%2Fwww.ient.fr%2Flogin%3Fprofil%3D2");
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
    final login = await request.post("https://auth.ient.fr/cas/login?service=https%3A%2F%2Fwww.ient.fr%2Flogin%3Fprofil%3D2", params);

    return login.isRedirect;
  }
}