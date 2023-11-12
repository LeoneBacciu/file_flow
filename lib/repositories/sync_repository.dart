import 'dart:convert' show json;
import 'dart:io';

import 'package:file_flow/models/document.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'drive_repository.dart';

class SyncRepository {
  final DriveRepository driveRepository;

  SyncRepository({required this.driveRepository});

  Future<Directory> getOrCreateDriveDirectory() async {
    final appDataDirectory = await getApplicationDocumentsDirectory();
    return Directory('${appDataDirectory.path}/drive')
      ..createSync(recursive: true);
  }

  Future<Directory> getOrCreateFilesDirectory() async {
    final appDataDirectory = await getApplicationDocumentsDirectory();
    return Directory('${appDataDirectory.path}/drive/files')
      ..createSync(recursive: true);
  }

  Future<File> getOrCreateSpec() async {
    final appDataDirectory = await getApplicationDocumentsDirectory();
    final spec = File('${appDataDirectory.path}/drive/spec.json');
    if (!spec.existsSync()) {
      spec.createSync(recursive: true);
      spec.writeAsStringSync('[]');
    }
    return spec;
  }

  Future<Map<String, File>> getFilesMap() async {
    final fileDir = await getOrCreateFilesDirectory();
    return Map.fromEntries(fileDir
        .listSync(followLinks: false)
        .whereType<File>()
        .map((f) => MapEntry(basename(f.path), f)));
  }

  Future<List<File>> copyFiles(List<File> files) async {
    final fileDir = await getOrCreateFilesDirectory();
    return files
        .map((e) => e.copySync(
            '${fileDir.path}/${const Uuid().v4()}${extension(e.path)}'))
        .toList();
  }

  File Function(String) getFile(Map<String, File> files) => (f) => files[f]!;

  Future<List<Document>> loadOffline() async {
    final spec = await getOrCreateSpec();
    final files = await getFilesMap();
    final parsed = List.from(json.decode(spec.readAsStringSync()));
    return parsed.map((d) => Document.fromJson(d, getFile(files))).toList();
  }

  Future<List<Document>> loadOnline() async {
    final spec = await getOrCreateSpec();
    final filesDir = await getOrCreateFilesDirectory();
    await driveRepository.downloadSpec(spec);
    await driveRepository.downloadFiles(filesDir);
    return await loadOffline();
  }

  Future<List<Document>> addDocument(
      List<Document> documents, Document document) async {
    final spec = await getOrCreateSpec();

    final copiedFiles = await copyFiles(document.files);
    document.files
      ..clear()
      ..addAll(copiedFiles);

    final documentsCopy = [...documents, document];

    spec.writeAsStringSync(
        json.encode(documentsCopy.map((d) => d.toJson()).toList()));

    await driveRepository.uploadSpec(spec);
    await driveRepository.uploadFiles(copiedFiles);

    return documentsCopy;
  }

  Future<List<Document>> deleteDocument(
      List<Document> documents, Document document) async {
    final documentsCopy = [...documents]..remove(document);

    final spec = await getOrCreateSpec();
    spec.writeAsStringSync(
        json.encode(documentsCopy.map((d) => d.toJson()).toList()));
    await driveRepository.uploadSpec(spec);

    for (final file in document.files) {
      await driveRepository.deleteFile(file);
    }

    await driveRepository.uploadSpec(spec);

    return documentsCopy;
  }

  Future<void> clearAll() async {
    final directory = await getOrCreateDriveDirectory();
    directory.deleteSync(recursive: true);
  }
}
