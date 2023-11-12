import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'google.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loginStatus = false;
  final googleSignIn = GoogleSignIn.standard(scopes: [
    drive.DriveApi.driveAppdataScope,
  ]);

  @override
  void initState() {
    _loginStatus = googleSignIn.currentUser != null;
    super.initState();
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
            TextButton(
              onPressed: _uploadToHidden,
              child: const Text('Upload'),
            ),
            TextButton(
              onPressed: _showList,
              child: const Text('Show'),
            ),
            TextButton(
              onPressed: _file,
              child: const Text('File'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _signIn,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showMessage(BuildContext context, String msg,
      String title) async {
    final alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("OK"),
        ),
      ],
    );
    await showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  Future<void> _signIn() async {
    final googleUser = await googleSignIn.signIn();

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
        print("Sign in");
        setState(() {
          _loginStatus = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    setState(() {
      _loginStatus = false;
    });
    print("Sign out");
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await googleSignIn.signIn();
    final headers = await googleUser?.authHeaders;
    if (headers == null) {
      await showMessage(context, "Sign-in first", "Error");
      return null;
    }

    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }

  Future<void> _uploadToHidden() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return;
      }
      // Not allow a user to do something else
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: Duration(seconds: 2),
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (context, animation, secondaryAnimation) =>
            Center(
              child: CircularProgressIndicator(),
            ),
      );
      // Create data here instead of loading a file
      const contents = "Technical Feeder";
      final Stream<List<int>> mediaStream =
      Future.value(contents.codeUnits).asStream().asBroadcastStream();
      var media = drive.Media(mediaStream, contents.length);

      // Set up File info
      var driveFile = drive.File();
      final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
      driveFile.name = "technical-feeder-$timestamp.txt";
      driveFile.modifiedTime = DateTime.now().toUtc();
      driveFile.parents = ["appDataFolder"];

      // Upload
      final response =
      await driveApi.files.create(driveFile, uploadMedia: media);
      print("response: $response");

      // simulate a slow process
      await Future.delayed(Duration(seconds: 2));
    } finally {
      // Remove a dialog
      Navigator.pop(context);
    }
  }

  Future<void> _showList() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return;
    }

    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      $fields: 'files(id, name, modifiedTime)',
    );
    final files = fileList.files;
    if (files == null) {
      return showMessage(context, "Data not found", "");
    }

    final alert = AlertDialog(
      title: Text("Item List"),
      content: SingleChildScrollView(
        child: ListBody(
          children: files.map((e) => Text(e.id ?? "no-name")).toList(),
        ),
      ),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  Future<void> _file() async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final img = InputImage.fromFile(File(result.files.single.path!));
      final RecognizedText recognizedText = await textRecognizer.processImage(img);

      String text = recognizedText.text;
      for (TextBlock block in recognizedText.blocks) {
        final rect = block.boundingBox;
        final cornerPoints = block.cornerPoints;
        final text = block.text;
        final languages = block.recognizedLanguages;

        for (TextLine line in block.lines) {
          // Same getters as TextBlock
          print(line.elements.map((e) => e.text).join(", "));
        }
      }
    } else {
      // User canceled the picker
    }

    textRecognizer.close();
  }
}
