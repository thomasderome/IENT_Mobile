import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:flutter/foundation.dart';

class HtmlParser {
  Future<Document> html_parse(String content) async {
    return compute(parse, content);
  }
}