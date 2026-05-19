import 'package:forui/forui.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import './request.dart';
import 'package:flutter/material.dart';

class VerifUpdate {
  static Future<void> check(BuildContext context) async {
    final HttpRequest request = HttpRequest();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final response = await request.get("https://api.github.com/repos/thomasderome/IENT_Mobile/releases/latest", Options());
    final String version = response.data["tag_name"].toString();

    debugPrint("ICI");
    debugPrint("online: $version installed: ${packageInfo.version}");

    if (version.replaceFirst("v", "") != packageInfo.version) {
      Uri url = Uri.parse("https://github.com/thomasderome/IENT_Mobile/releases/download/$version/app-release.apk");
      dialog(context, url);
    }
  }

  static Future<void> open_link(BuildContext context, Uri url) async {
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Navigator.of(context).pop();
    }
  }

  static void dialog(BuildContext context, Uri url) {
    showFDialog(
      context: context,
      builder: (context, style, animation) => FDialog(
        style: style,
        animation: animation,
        title: const Text('Mise à jour'),
        body: const Text('Une mise à jour est disponible !'),
        actions: [
          FButton(
              onPress: () => open_link(context, url),
              child: const Text("Télécharger")
          ),
          FButton(
            onPress: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}