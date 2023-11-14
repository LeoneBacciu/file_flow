import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImagesPreview extends StatelessWidget {
  final List<File> images;

  const ImagesPreview({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: images.length,
      itemBuilder: (context, index) => Center(
        child: InkWell(
          onLongPress: () => Share.shareXFiles(
            [XFile(images[index].path)],
          ),
          child: Card(
            elevation: 4,
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Hero(
              tag: images[index].path,
              child: Image.file(images[index]),
            ),
          ),
        ),
      ),
    );
  }
}
