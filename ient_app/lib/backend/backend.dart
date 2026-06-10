import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'request.dart';
import 'html_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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
    Response verif;

    if (kIsWeb) {
        verif = login;
    } else {
        String redirect_url = login.headers.value("location") ?? "";
        if (redirect_url != "") { verif = await request.redirect_system(redirect_url); }
        else { return false; }
    }

    if (verif.headers.value("finish_link")?.endsWith("/Welcome") ?? false || verif.realUri.toString().endsWith("/Welcome")) {
        home_page = await parser.html_parse(verif.data);

        final Map<String, String> account = {
            "login": username,
            "password": password
        };

        final FlutterSecureStorage keystore = FlutterSecureStorage();
        await keystore.write(key: "account", value: jsonEncode(account));
        return true;
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

      temp.sort((m1, m2) {
        var r = m1["start"].compareTo(m2["start"]);
        if (r != 0) return r;
        return m1["start"].compareTo(m2["start"]);
      });

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

  Future<Map<String, List>> get_work() async {
    final Iterable<String>? work_week = home_page?.querySelectorAll("a[href^='/cahiertexte/travail?date=']").map((e) => e.attributes["href"]!).toSet();

    Map<String, List> work = {};
    for (final week in work_week!) {
      final work_page = await request.get("https://www.ient.fr$week", Options());
      final work_html = await parser.html_parse(work_page.data);

      for (Element day in work_html.querySelectorAll("div[class^='col-sm-1 col-12']")) {
        final String? date = day.querySelector("div[class='entete-jour_planning']")?.text.trim();
        final works_day = day.querySelectorAll('div[id^="modal_"]');

        for (Element work_day in works_day) {
          if (work[date] == null) work[date!] = [];

          work[date]?.add({
            "title": work_day.getElementsByTagName("h3")[0].text.trim(),
            "desc_detail": work_day.querySelector('div[class^="modal-body"]')?.querySelector("div[style^='padding-left:10px;padding-right:10px;']")?.text.trim(),
            "doc": work_day.querySelectorAll('a[href]').map((e) => {"name": e.text, "link": "https://www.ient.fr${e.attributes['href']}"}).toList(),
          });
        }
      }
    }
    return work;
  }

  Future<void> render_file(String url) async {
    if (kIsWeb) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      final String path_download = await request.download(url);
      await OpenFile.open(path_download);
    }
  }

  Future<List<Map>> get_note() async {
    final Response request_notes = await request.get("https://www.ient.fr/notes", Options());
    final Document notes_parse = await parser.html_parse(request_notes.data);
    List<Map<String, dynamic>> data = [];

    final List<Element> note_by_prof = notes_parse.querySelectorAll('.card-body > div.row');

    for (Element notes_prof in note_by_prof) {
      final String? prof = notes_prof.querySelector("small.formateur")?.text.trim();
      final String? matiere = notes_prof.querySelector("div.matiere")?.text.trim() ?? "";

      if (prof == null || prof.isEmpty) continue;

      final List<Element> list_note = notes_prof.querySelectorAll("div.col-lg-1.border-notes");

      List<Map<String, String>> note_temp = [];
      double somme = 0.0;
      double number = 0.0;

      for (Element note in list_note) {
        final String date = note.querySelector("small.note-date")?.text.trim() ?? "";
        final String note_on = note.querySelector("small.note-sur")?.text.trim() ?? "";
        final String final_note = note.querySelector("span.note-note")?.text.trim() ?? "";

        if (final_note.trim().isEmpty || note_on.trim().isEmpty) {
          break;
        }

        final String coeff = note.querySelector("div[id\$='_bulle'] small")?.text.trim() ?? "";
        final String name = note.querySelector("div[id\$='_bulle'] div.detail-absences-txt")?.text.trim() ?? "";

        note_temp.add({
          "name": name,
          "date": date,
          "final_note": final_note,
          "note_on": note_on,
          "coeff": coeff
        });

        double? noteVal = double.tryParse(final_note);
        double? totalVal = double.tryParse(note_on.replaceAll("/", "").trim());

        String coeffNettoye = coeff.replaceAll(RegExp(r'[^0-9.]'), '');
        double coeffVal = double.tryParse(coeffNettoye) ?? 1.0;

        if (noteVal != null && totalVal != null && totalVal > 0) {
          somme += (noteVal * 20 / totalVal) * coeffVal;
          number += coeffVal;
        }
      }

      if (note_temp.isNotEmpty) {
        data.add({
          "matiere": matiere,
          "prof_name": prof,
          "notes": note_temp,
          "moyenne": number > 0 ? (somme / number).toStringAsFixed(2) : "N/A",
        });
      }
    }
    return data;
  }
}