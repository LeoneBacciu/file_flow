import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class AuthWrapper extends InheritedWidget {
  final GoogleSignIn googleSignIn;

  const AuthWrapper({
    super.key,
    required this.googleSignIn,
    required super.child,
  });

  static AuthWrapper? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthWrapper>();
  }

  static AuthWrapper of(BuildContext context) {
    final AuthWrapper? result = maybeOf(context);
    assert(result != null, 'No AuthWidget found in context');
    return result!;
  }

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

  @override
  bool updateShouldNotify(AuthWrapper oldWidget) =>
      googleSignIn != oldWidget.googleSignIn;
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

class CustomException implements Exception {
  String cause;
  CustomException(this.cause);
}
