import 'request.dart';
import 'html_parser.dart';
import 'package:flutter_keystore/flutter_keystore.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:flutter/material.dart' as mat;

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

  // Variable cache
  Document? home_page = null;

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

      if (verif.realUri.toString() == "https://www.ient.fr/Welcome") {
        home_page = await parser.html_parse(verif.data);

        final FlutterKeystore keyStore = FlutterKeystore();

        await keyStore.write("username", username);
        await keyStore.write("password", password);

        return true;
      }
    }
    return false;
  }

  Future<Map> get_planning({String date_custom = ""}) async {
    // 2026-02-16
    Response response = await request.get("https://www.ient.fr/planninghebdo?date=$date_custom", Options());
    Document planning_parse = await parser.html_parse(response.data);

    List<Element> days = planning_parse.getElementsByClassName("col-sm-1 col-12");
    RegExp reg = RegExp(r"top:\s*([\d.]+)px;?\s*height:\s*([\d.]+)px");

    DateTime date_today = DateTime.now();
    String date_today_str = date_today.day <= 10 ? "0${date_today.day}":"${date_today.day}";

    int to_day = date_custom == "" ? 1 : date_today.isAfter(DateTime.parse(date_custom)) ? 5 : 1;
    Map temp_days = {};
    int count = 1;

    for (Element day in days) {
      List<Map> temp = [];

      String date = day.getElementsByClassName("entete-jour_planning")[0].text.trim();
      List<Element> sequences = day.getElementsByClassName("sequence");

      for (Element sequence in sequences) {
        if (sequence.id != "") {
          String style = sequence.attributes["style"] ?? "";
          Match? match = reg.firstMatch(style)!;

          double start = double.parse(match.group(1)!).round() / 21;
          double time = (double.parse(match.group(2)!).round() + 3) / 21;

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

      temp_days[count] = {
        "day": date,
        "activity": temp
      };

      if (date.split(" ")[1] == date_today_str && date_custom == "") { to_day = count; }
      count++;
    }

    Map result = {
      "day_select": to_day,
      "original": to_day,
      "date_select": date_custom == "" ? "${date_today.year}-${date_today.month >= 10 ? date_today.month : '0${date_today.month}'}-${date_today.day >= 10 ? date_today.day : '0${date_today.day}'}" : date_custom,
      "days": temp_days
    };

    return result;
  }
}