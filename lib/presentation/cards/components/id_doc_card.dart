import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/preview/preview_page.dart';
import 'package:flutter/material.dart';

class CardsCard extends StatelessWidget {
  final Document document;

  const CardsCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(document: document),
          ),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 85.60 / 53.98,
              child: Hero(
                tag: document.preview.path,
                child: Image.file(document.preview),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                document.name,
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
