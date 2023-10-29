import 'dart:convert' show json;

import 'package:file_flow/models/document.dart';
import 'package:flutter/services.dart' show rootBundle;

class DriveRepository {
  static Future<List<Document>> loadSpec() async {
    final file = await rootBundle.loadString('assets/test.json');
    final parsed = List.from(json.decode(file));
    return parsed.map((e) => Document.fromJson(e)).toList();
  }
}
