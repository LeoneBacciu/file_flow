import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../core/functions.dart';
import '../core/optimistic_update.dart';
import '../models/document.dart';
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
        .map((e) => e.parent.path == fileDir.path
            ? e
            : e.copySync('${fileDir.path}/${uuid4()}.jpeg'))
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

  Future<DocumentList> loadOffline() async {
    final spec = await getOrCreateSpec();
    final files = await getFilesMap();
    final docs = Document.deserialize(spec.readAsStringSync(), (f) => files[f]!)
        .frozen();
    cleanupFiles(docs.extractFiles());
    return docs;
  }

  Future<DocumentList> loadOnline() async {
    final spec = await getOrCreateSpec();
    final filesDir = await getOrCreateFilesDirectory();
    await driveRepository.downloadSpec(spec);
    await driveRepository.downloadFiles(filesDir);
    final docs = await loadOffline();
    driveRepository.cleanupFiles(docs.extractFiles());
    return docs;
  }

  Future<OptimisticUpdate<DocumentList>> addDocument(
      DocumentList documents, Document document) async {
    final spec = await getOrCreateSpec();

    final copiedFiles = await copyFiles(document.files);
    document.files
      ..clear()
      ..addAll(copiedFiles);

    final documentsCopy = [...documents, document].frozen();

    spec.writeAsStringSync(documentsCopy.serialize());

    return OptimisticUpdate(
      value: documentsCopy,
      onSend: (_) => driveRepository
          .uploadFiles(copiedFiles)
          .whenComplete(() => driveRepository.uploadSpec(spec)),
      onError: (_) async {
        spec.writeAsStringSync(documents.serialize());
        await cleanupFiles(documents.extractFiles());
        return documents;
      },
    );
  }

  Future<OptimisticUpdate<DocumentList>> editDocument(
      DocumentList documents, Document document) async {
    final spec = await getOrCreateSpec();

    final copiedFiles = await copyFiles(document.files);
    document.files
      ..clear()
      ..addAll(copiedFiles);

    final documentsCopy = ([...documents]..replaceUuid(document)).frozen();

    spec.writeAsStringSync(documentsCopy.serialize());

    return OptimisticUpdate(
      value: documentsCopy,
      onSend: (d) => driveRepository.uploadFiles(copiedFiles).whenComplete(() =>
          driveRepository.uploadSpec(spec).whenComplete(
              () => driveRepository.cleanupFiles(d.extractFiles()))),
      onSuccess: (d) => cleanupFiles(d.extractFiles()),
      onError: (_) async {
        spec.writeAsStringSync(documents.serialize());
        await cleanupFiles(documents.extractFiles());
        return documents;
      },
    );
  }

  Future<OptimisticUpdate<DocumentList>> removeDocument(
      DocumentList documents, Document document) async {
    final documentsCopy = ([...documents]..remove(document)).frozen();

    final spec = await getOrCreateSpec();
    spec.writeAsStringSync(documentsCopy.serialize());

    return OptimisticUpdate(
      value: documentsCopy,
      onSend: (_) => driveRepository
          .uploadSpec(spec)
          .whenComplete(() => driveRepository.removeFiles(document.files)),
      onSuccess: (d) => cleanupFiles(d.extractFiles()),
      onError: (_) async {
        spec.writeAsStringSync(documents.serialize());
        return documents;
      },
    );
  }

  Future<void> clearLocal() async {
    final directory = await getOrCreateDriveDirectory();
    directory.deleteSync(recursive: true);
  }
}
