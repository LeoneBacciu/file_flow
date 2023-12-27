import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/components/separator.dart';
import '../../core/convert.dart';
import '../../models/document.dart';
import 'add_page.dart';

class AddLoaderPage extends StatelessWidget {
  final List<File> files;

  const AddLoaderPage({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FilesConverter.convert(files),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AddPage(
                  category: DocumentCategory.other,
                  initialImages: snapshot.data!,
                ),
              ),
            );
          });
        }
        return const Scaffold(
          appBar: null,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sto importando...',
                  style: TextStyle(fontSize: 24),
                ),
                Separator.height(12),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
