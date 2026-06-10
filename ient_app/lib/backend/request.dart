import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/browser.dart';

class HttpRequest {
  late Dio dio;
  final CookieJar cookieJar = CookieJar();

  // URL de votre proxy CORS (à modifier par la vôtre)
  final String proxyUrl = "http://127.0.0.1:3000/api/?url=";

  HttpRequest() {
    dio = Dio(BaseOptions(
      extra: <String, dynamic>{
              'withCredentials': true,
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "X-Requested-With": "XMLHttpRequest",
        if (!kIsWeb)
          "User-Agent": "Mozilla/5.0 (Linux; Android 9; motorola one vision) AppleWebKit/537.36",
      },
      followRedirects: false,
      validateStatus: (status) {
        return status != null && status < 400;
      },
    ));
    if (kIsWeb) {
      (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
    } else {
      dio.interceptors.add(CookieManager(cookieJar));
    }
  }

  String _wrapUrl(String url) {
    if (kIsWeb && !url.startsWith(proxyUrl)) {
      return "$proxyUrl$url";
    }
    return url;
  }

  Future<Response> get(String url, Options? options) async {
    Response response = await dio.get(_wrapUrl(url), options: options);
    return response;
  }

  Future<Response> post(String url, Map<String, String> params, Options? options) async {
    Response response = await dio.post(_wrapUrl(url), options: options, data: params);
    return response;
  }

  Future<Response> redirect_system(String url) async {
    Response response = await dio.get(_wrapUrl(url));
    String redirect = response.headers.value("location") ?? "";

    while (redirect != "") {
      response = await dio.get(_wrapUrl(redirect));
      redirect = response.headers.value("location") ?? "";
    }
    return response;
  }

  Future<String> download(String url) async {
    if (kIsWeb) {
      final Uri uri = Uri.parse(url);
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return "web_download_started";
      }
      throw Exception("Could not launch $url");
    }

    Uri uri = Uri.parse(url);

    Directory tempDir = await getTemporaryDirectory();
    String file_name = uri.queryParameters["nom"] ?? "";
    String savePath = "${tempDir.path}/${file_name.isEmpty ? uri.pathSegments.last : file_name}";

    await dio.download(url, savePath);
    return savePath;
  }

}