import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerModal extends StatelessWidget {
  const FilePickerModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => openScanner().then((f) {
              if (f != null) Navigator.of(context).pop(f);
            }),
            child: Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                Icons.camera_alt,
                size: 50,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => openFilePicker().then((f) {
              if (f != null) Navigator.of(context).pop(f);
            }),
            child: Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                Icons.storage,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<File>?> openScanner() async {
    final imagesPath = await CunningDocumentScanner.getPictures(true);
    return imagesPath?.map((f) => File(f)).toList();
  }

  Future<List<File>?> openFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: true,
    );
    return result?.files.map((f) => File(f.path!)).toList();
  }
}
