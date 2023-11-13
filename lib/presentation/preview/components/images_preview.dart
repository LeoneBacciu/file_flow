import 'dart:io';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

class ImagesPreview extends StatelessWidget {
  final List<File> images;

  const ImagesPreview({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ExpandablePageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) => Center(
        child: Card(
          elevation: 4,
          clipBehavior: Clip.hardEdge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Image.file(images[index]),
        ),
      ),
    );
  }
}
