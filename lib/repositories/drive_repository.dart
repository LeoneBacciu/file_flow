import 'dart:convert' show json;
import 'dart:io';

import 'package:file_flow/models/document.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DriveRepository {
  static final DriveRepository _instance = DriveRepository._constructor();

  factory DriveRepository() {
    return _instance;
  }

  DriveRepository._constructor();

  Future<Directory> getOrCreateDirectory() async {
    final appDataDirectory = await getApplicationDocumentsDirectory();
    return Directory('${appDataDirectory.path}/drive')
      ..createSync(recursive: true);
  }

  Future<File> getOrCreateSpec(Directory directory) async {
    final spec = File('${directory.path}/spec.json');
    if (!spec.existsSync()) {
      spec.createSync(recursive: true);
      spec.writeAsStringSync('[]');
    }
    return spec;
  }

  Future<Map<String, File>> getFilesMap(Directory directory) async {
    final fileDir = Directory('${directory.path}/files')
      ..createSync(recursive: false);
    return Map.fromEntries(fileDir
        .listSync(followLinks: false)
        .whereType<File>()
        .map((f) => MapEntry(basename(f.path), f)));
  }

  List<File> copyFiles(Directory directory, List<File> files) {
    final fileDir = Directory('${directory.path}/files')
      ..createSync(recursive: false);
    return files
        .map((e) => e.copySync('${fileDir.path}/${const Uuid().v4()}${extension(e.path)}'))
        .toList();
  }

  File Function(String) getFile(Map<String, File> files) => (f) => files[f]!;

  Future<List<Document>> loadDocuments() async {
    final directory = await getOrCreateDirectory();
    final spec = await getOrCreateSpec(directory);
    final files = await getFilesMap(directory);
    final parsed = List.from(json.decode(spec.readAsStringSync()));
    return parsed.map((d) => Document.fromJson(d, getFile(files))).toList();
  }

  Future<List<Document>> updateDocuments(
      List<Document> documents, Document document) async {
    final directory = await getOrCreateDirectory();
    final spec = await getOrCreateSpec(directory);

    final copiedFiles = copyFiles(directory, document.files);
    document.files
      ..clear()
      ..addAll(copiedFiles);

    documents.add(document);


    try {
      final jsonList=documents.map((d) => d.toJson()).toList();
      print(jsonList);
      spec.writeAsStringSync(json.encode(jsonList));
    } catch (e, s) {
      print(s.toString());
    }
    return documents;
  }
}
