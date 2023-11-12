import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class DriveRepository {
  static const appDataFolder = 'appDataFolder';
  static const specFileName = 'spec.json';
  static const filesFolderName = 'files';
  static const folderMimeType = 'application/vnd.google-apps.folder';
  static const jsonMimeType = 'application/json';
  static const defaultFileFields = 'files(id, name)';
  final GoogleSignIn googleSignIn =
      GoogleSignIn.standard(scopes: [drive.DriveApi.driveAppdataScope]);

  Future<GoogleSignInAccount?> get user => googleSignIn.signIn();

  Future<drive.DriveApi?> get driveApi async {
    final googleUser = await user;
    final headers = await googleUser?.authHeaders;
    if (headers == null) return null;

    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }

  Future<void> signIn() async {
    final googleUser = await user;

    try {
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential loginUser =
            await FirebaseAuth.instance.signInWithCredential(credential);

        assert(loginUser.user?.uid == FirebaseAuth.instance.currentUser?.uid);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
  }

  Future<drive.File?> getOrCreateSpec() async {
    final api = await driveApi;
    if (api == null) return null;

    final spec = await api.files.list(
      spaces: appDataFolder,
      q: "name = '$specFileName' and mimeType = '$jsonMimeType'",
      $fields: defaultFileFields,
    );
    if (spec.files?.isEmpty ?? true) {
      const defaultSpec = '[]';
      final mediaStream = Future.value(defaultSpec.codeUnits).asStream();
      return await api.files.create(
        drive.File(
          name: specFileName,
          mimeType: jsonMimeType,
          parents: [appDataFolder],
        ),
        uploadMedia: drive.Media(mediaStream, defaultSpec.length),
      );
    }
    return spec.files?.first;
  }

  Future<drive.File?> getOrCreateFilesFolder() async {
    final api = await driveApi;
    if (api == null) return null;

    final fileFolder = await api.files.list(
      spaces: appDataFolder,
      q: "name = '$filesFolderName' and mimeType = '$folderMimeType'",
      $fields: defaultFileFields,
    );
    if (fileFolder.files?.isEmpty ?? true) {
      return await api.files.create(drive.File(
        name: filesFolderName,
        mimeType: folderMimeType,
        parents: [appDataFolder],
      ));
    }
    return fileFolder.files?.first;
  }

  Future<bool> downloadSpec(File spec) async {
    final api = await driveApi;
    if (api == null) return false;

    final remoteSpec = await getOrCreateSpec();
    if (remoteSpec == null) return false;

    final remoteSpecSource = await api.files.get(
      remoteSpec.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (remoteSpecSource is drive.Media) {
      final bytes = await remoteSpecSource.stream.expand((i) => i).toList();
      spec.writeAsBytesSync(bytes);
    }
    return true;
  }

  Future<bool> downloadFiles(Directory directory) async {
    final api = await driveApi;
    if (api == null) return false;

    final filesFolder = await getOrCreateFilesFolder();
    if (filesFolder == null) return false;

    final remoteFiles = await api.files.list(
      spaces: appDataFolder,
      q: "'${filesFolder.id}' in parents and mimeType != '$folderMimeType'",
      $fields: defaultFileFields,
    );
    for (final remoteFile in remoteFiles.files!) {
      final remoteFileSource = await api.files.get(
        remoteFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );
      if (remoteFileSource is drive.Media) {
        final bytes = await remoteFileSource.stream.expand((i) => i).toList();
        File('${directory.path}/${remoteFile.name}').writeAsBytesSync(bytes);
      }
    }
    return true;
  }

  Future<bool> uploadSpec(File spec) async {
    final api = await driveApi;
    if (api == null) return false;

    final oldSpec = await getOrCreateSpec();
    if (oldSpec == null) return false;

    final bytes = spec.readAsBytesSync().toList();

    await api.files.update(
      drive.File(
        name: specFileName,
        mimeType: jsonMimeType,
      ),
      oldSpec.id!,
      uploadMedia: drive.Media(
        Future.value(bytes).asStream(),
        bytes.length,
      ),
    );
    return true;
  }

  Future<bool> uploadFiles(List<File> files) async {
    final api = await driveApi;
    if (api == null) return false;

    final filesFolder = await getOrCreateFilesFolder();
    if (filesFolder == null) return false;

    for (final localFile in files) {
      final bytes = localFile.readAsBytesSync().toList();

      await api.files.create(
        drive.File(
          name: basename(localFile.path),
          parents: [filesFolder.id!],
        ),
        uploadMedia: drive.Media(
          Future.value(bytes).asStream(),
          bytes.length,
        ),
      );
    }
    return true;
  }

  Future<bool> deleteFile(File file) async {
    final api = await driveApi;
    if (api == null) return false;

    final filesFolder = await getOrCreateFilesFolder();
    if (filesFolder == null) return false;

    final remoteFiles = await api.files.list(
      spaces: appDataFolder,
      q: "'${filesFolder.id}' in parents and name = '${basename(file.path)}' and mimeType != '$folderMimeType'",
      $fields: defaultFileFields,
    );
    for (final remoteFile in remoteFiles.files!) {
      await api.files.delete(remoteFile.id!);
    }
    return true;
  }

  Future<bool> deleteFiles() async {
    final api = await driveApi;
    if (api == null) return false;

    final filesFolder = await getOrCreateFilesFolder();
    if (filesFolder == null) return false;

    final remoteFiles = await api.files.list(
      spaces: appDataFolder,
      q: "'${filesFolder.id}' in parents and mimeType != '$folderMimeType'",
      $fields: defaultFileFields,
    );
    for (final remoteFile in remoteFiles.files!) {
      await api.files.delete(remoteFile.id!);
    }
    return true;
  }

  Future<bool> deleteAll() async {
    final api = await driveApi;
    if (api == null) return false;

    final remoteFiles = await api.files.list(
      spaces: appDataFolder,
      $fields: defaultFileFields,
    );
    for (final remoteFile in remoteFiles.files!) {
      await api.files.delete(remoteFile.id!);
    }
    return true;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
