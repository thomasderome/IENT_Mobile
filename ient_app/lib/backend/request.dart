import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class HttpRequest {
  late Dio dio;
  final CookieJar cookieJar = CookieJar();

  HttpRequest() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        "User-Agent": "Mozilla/5.0 (Linux; Android 9; motorola one vision) AppleWebKit/537.36",
      },
    ));
    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(LogInterceptor(
      requestHeader: true,  // Pour voir les cookies envoyés
      responseHeader: true, // Pour voir les cookies reçus (Set-Cookie)
      requestBody: true,
      responseBody: false,
    ));
  }

  Future<Response> get(String url) async {
    final response = await dio.get(url);
    return response;
  }

  Future<Response> post(String url, Map<String, String> params) async {
    final response = await dio.post(url, options: Options(
        followRedirects: true,
        contentType: "application/x-www-form-urlencoded",
      ),
      data: params,
    );
    return response;
  }
}