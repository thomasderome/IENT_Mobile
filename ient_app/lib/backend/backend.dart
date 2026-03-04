import 'request.dart';
import 'html_parser.dart';
import 'package:flutter/material.dart' as mat;
import 'package:dio/dio.dart';
import 'package:html/dom.dart';

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

    if (redirect_url != "") {
      Response verif = await request.redirect_system(redirect_url);
      if (verif.realUri.toString() == "https://www.ient.fr/Welcome") return true;

      return false;
    }
    else return false;
  }

  Future<Map> get_planning({String date = ""}) async {
    // 2026-02-16
    Response response = await request.get("https://www.ient.fr/planninghebdo?date=$date", Options());
    Document planning_parse = await parser.html_parse(response.data);

    List<Element> days = planning_parse.getElementsByClassName("col-sm-1 col-12");
    RegExp reg = RegExp(r"top:\s*([\d.]+)px;?\s*height:\s*([\d.]+)px");

    Map result = {};

    String date_today = DateTime.now().day.toString();
    int count = 1;

    for (Element day in days) {
      List<Map> temp = [];

      String date = day.getElementsByClassName("entete-jour_planning")[0].text
          .trim();
      List<Element> sequences = day.getElementsByClassName("sequence");

      for (Element sequence in sequences) {
        if (sequence.id != "") {
          String style = sequence.attributes["style"] ?? "";
          Match? match = reg.firstMatch(style)!;

          double start = int.parse(match.group(1)!) / 21;
          double time = (int.parse(match.group(2)!) + 3) / 21;
          
          List<Element> data_activity = sequence.getElementsByClassName("txt_planning");

          temp.add({
            "name": data_activity[0].text.trim(),
            "prof": data_activity[1].text.trim(),
            "room": data_activity[2].text.trim(),
            "time": time,
            "start": start
          });
        } else {
          temp.add({
            "name": sequence.text.trim(),
            "prof": "",
            "room": "",
            "time": 26,
            "start": 0
          });
        }
      }

      result[date.split(" ")[1] == date_today ? -1:count]({
        "day": date,
        "activity": temp
      });

      count++;
    }
    return result;
  }
}