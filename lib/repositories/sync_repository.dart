import 'dart:io';

import 'package:file_flow/core/optimistic_call.dart';
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

  Future<void> cleanupFiles(List<File> files) async {
    final fileDir = await getOrCreateFilesDirectory();
    Future.wait(fileDir
        .listSync(followLinks: false)
        .where((f) => !files.containsPath(f.path))
        .cast<File>()
        .map((f) => f.delete()));
  }

  Future<List<Document>> loadOffline() async {
    final spec = await getOrCreateSpec();
    final files = await getFilesMap();
    final docs =
        Document.deserialize(spec.readAsStringSync(), (f) => files[f]!);
    cleanupFiles(docs.getFiles());
    return docs;
  }

  Future<List<Document>> loadOnline() async {
    final spec = await getOrCreateSpec();
    final filesDir = await getOrCreateFilesDirectory();
    await driveRepository.downloadSpec(spec);
    await driveRepository.downloadFiles(filesDir);
    final docs = await loadOffline();
    driveRepository.cleanupFiles(docs.getFiles());
    return docs;
  }

  Future<OptimisticCall<List<Document>>> addDocument(
      List<Document> documents, Document document) async {
    final spec = await getOrCreateSpec();

    final copiedFiles = await copyFiles(document.files);
    document.files
      ..clear()
      ..addAll(copiedFiles);

    final documentsCopy = [...documents, document];

    spec.writeAsStringSync(documentsCopy.serialize());

    return OptimisticCall(
      value: documentsCopy,
      onSend: (_) => Future.wait([
        driveRepository.uploadSpec(spec),
        driveRepository.uploadFiles(copiedFiles)
      ]),
      onError: (_) async {
        spec.writeAsStringSync(documents.serialize());
        await cleanupFiles(documents.getFiles());
        return documents;
      },
    );
  }

  Future<OptimisticCall<List<Document>>> updateDocument(
      List<Document> documents, Document document) async {
    final spec = await getOrCreateSpec();

    final copiedFiles = await copyFiles(document.files);
    document.files
      ..clear()
      ..addAll(copiedFiles);

    final documentsCopy = [...documents]..replace(document);

    spec.writeAsStringSync(documentsCopy.serialize());

    return OptimisticCall(
      value: documentsCopy,
      onSend: (d) => Future.wait([
        driveRepository
            .uploadSpec(spec)
            .then((value) => driveRepository.cleanupFiles(d.getFiles())),
        driveRepository.uploadFiles(copiedFiles)
      ]),
      onError: (_) async {
        spec.writeAsStringSync(documents.serialize());
        await cleanupFiles(documents.getFiles());
        return documents;
      },
    );
  }

  Future<OptimisticCall<List<Document>>> deleteDocument(
      List<Document> documents, Document document) async {
    final documentsCopy = [...documents]..remove(document);

    final spec = await getOrCreateSpec();
    spec.writeAsStringSync(documentsCopy.serialize());

    return OptimisticCall(
      value: documentsCopy,
      onSend: (_) => Future.wait([
        driveRepository.uploadSpec(spec),
        driveRepository.deleteFiles(document.files),
      ]),
      onSuccess: (_) => Future.wait(document.files.map((f) => f.delete())),
      onError: (_) async {
        spec.writeAsStringSync(documents.serialize());
        return documents;
      },
    );
  }

  Future<void> clearAll() async {
    final directory = await getOrCreateDriveDirectory();
    directory.deleteSync(recursive: true);
  }
}
