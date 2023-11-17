import 'dart:io';

import 'package:file_flow/core/components/common.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImagesPreview extends StatelessWidget {
  final List<File> images;

  final NavigationRoute heroRoute;

  const ImagesPreview({
    super.key,
    required this.images,
    required this.heroRoute,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: images.length,
      itemBuilder: (context, index) => Center(
        child: InkWell(
          onLongPress: () => Share.shareXFiles(
            [XFile(images[index].path)],
          ),
          child: Card(
            elevation: 4,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Hero(
              tag: '$heroRoute-${images[index].path}',
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(images[index])),
            ),
          ),
        ),
      ),
    );
  }
}
