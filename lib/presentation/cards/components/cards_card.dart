import 'package:flutter/material.dart';

import '../../../core/components/common.dart';
import '../../../models/document.dart';
import '../../preview/preview_page.dart';

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
            builder: (context) => PreviewPage(
              heroRoute: NavigationRoute.cards,
              document: document,
            ),
          ),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 85.60 / 53.98,
              child: Hero(
                tag: '${NavigationRoute.cards}-${document.preview.path}',
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(document.preview, fit: BoxFit.cover)),
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
