import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';

class HttpRequest {
  late Dio dio;
  final CookieJar cookieJar = CookieJar();

  HttpRequest() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "User-Agent": "Mozilla/5.0 (Linux; Android 9; motorola one vision) AppleWebKit/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      },
      followRedirects: false,
      validateStatus: (status) {
        return status != null && status < 400;
      },
    ));
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<Response> get(String url, Options? options) async {
    Response response = await dio.get(url, options: options);
    return response;
  }

  Future<Response> post(String url, Map<String, String> params, Options? options) async {
    Response response = await dio.post(url, options: options, data: params);
    return response;
  }

  Future<Response> redirect_system(String url) async {
    Response response = await dio.get(url);
    String redirect = response.headers.value("location") ?? "";

    while (redirect != "") {
      response = await dio.get(redirect);
      redirect = response.headers.value("location") ?? "";
    }
    return response;
  }
}