import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/edit/edit_page.dart';
import 'package:file_flow/presentation/preview/components/images_preview.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PreviewPage extends StatefulWidget {
  final Document document;

  const PreviewPage({super.key, required this.document});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EditPage(document: widget.document),
              ),
            ),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImagesPreview(images: widget.document.files),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Share.shareXFiles(
          widget.document.files.map((f) => XFile(f.path)).toList(),
          subject: widget.document.name,
          text: widget.document.name,
        ),
        child: const Icon(Icons.share),
      ),
    );
  }
}
